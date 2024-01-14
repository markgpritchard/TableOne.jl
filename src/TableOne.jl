
module TableOne

using DataFrames, HypothesisTests, StatsBase, UnPack

export tableone

"""
    tableone(data, strata[, vars]; <keyword arguments>)

Produce a summary table which may be used as Table 1 in a manuscript.

## Arguments 
* `data`: A `DataFrame` containing the data to be included in the table
* `strata`: The variable (a column in `data`) by which the data should be stratified 
    in the table
* `vars`: The variables to be listed in the table, defaults to `Symbol.(names(data))` 
    if not supplied

# Keyword arguments

## Types of variables 
Each of these must be supplied as the same type as `vars`, e.g. if `vars` is a `Vector{Symbol}` 
    then these should each be a `Vector{Symbol}`. Variables supplied to one of these 
    arguments but not the main `vars` argument will not be displayed.
* `binvars`: binary variables – variable will take one row and show **number (%)** 
    with the selected level (see `binvardisplay` below)
* `catvars`: categorical variables – each level in the variable will be shown on 
    a separate line with the **number (%)** in that category
* `npvars`: non-parametric variables – will display **median [1st–3rd quartiles]**

Any variables not included in one of these arguments will be presented as 
    `mean (standard deviation)` if the contents of the variable are 
    `<:Union{<:Number, Missing}`, and as categorical otherwise.

## Additional keyword arguments 
* `addnmissing = true`: include the numer of records with missing values for each 
    variable. If `true`, will also display number with missing `strata` values
* `addtotal = false`: include a column of totals across all `strata`
* `binvardisplay = nothing`: optionally, a `Dict` to choose the level to display 
    for binary values. Any variables not listed will use the value chosen by `maximum(skipmissing(.))`
* `digits = 1`: number of digits to be displayed after the decimal place in means, 
    standard deviations and percentages
* `includemissingintotal = false`: include records with missing stratification variable 
    in the totals column. This option has no effect if `addtotal == false`
* `pdigits = 3`: number of digits to be displayed after the decimal place for p-values
* `pvalues = false`: whether to display significant test p-values for each variable 
    in the table
* `varnames = nothing`: optionally, a `Dict` of names for variables different 
    from the column titles in `data`, of the form `Dict(:columnname => "name to print")`. 
    Any variables not included will be listed by the column name

# Examples
```jldoctest
julia> using TableOne, CSV, DataFrames, Downloads

julia> # use the public PBC dataset

julia> pbcdata = CSV.read(
    Downloads.download("http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv"),
    DataFrame;
    missingstring = "NA")
[...]

julia> tableone(
    pbcdata,
    :trt,
    [ "age", "sex", "hepato", "edema", "bili", "chol", "stage" ];
    binvars = [ "sex", "hepato" ],
    catvars = [ "edema", "stage" ],
    npvars = [ "bili", "chol" ],
    digits = 2,
    binvardisplay = Dict("sex" => "f"),
    varnames = Dict(
        "age" => "Age, years",
        "hepato" => "Hepatomegaly", 
        "bili" => "Bilirubin, mg/dL", 
        "chol" => "Cholesterol, mg/dL"
    )
)
15×4 DataFrame
 Row │ variablenames                     1                     2                     nmissing 
     │ String                            String                String                String   
─────┼────────────────────────────────────────────────────────────────────────────────────────
   1 │ n                                 158                   154                   106      
   2 │ Age, years: mean (sd)             51.42 (11.01)         48.58 (9.96)          0
   3 │ sex: f                            137 (86.71)           139 (90.26)           0
   4 │ Hepatomegaly: 1                   73 (46.2)             87 (56.49)            0
   5 │ edema                                                                         0
   6 │     0.0                           132 (83.54)           131 (85.06)
   7 │     0.5                           16 (10.13)            13 (8.44)
   8 │     1.0                           10 (6.33)             10 (6.49)
   9 │ Bilirubin, mg/dL: median [IQR]    1.4 [0.8–3.2]         1.3 [0.72–3.6]        0
  10 │ Cholesterol, mg/dL: median [IQR]  315.5 [247.75–417.0]  303.5 [254.25–377.0]  28
  11 │ stage                                                                         0
  12 │     1                             12 (7.59)             4 (2.6)
  13 │     2                             35 (22.15)            32 (20.78)
  14 │     3                             56 (35.44)            64 (41.56)
  15 │     4                             55 (34.81)            54 (35.06)
```
"""
function tableone(data, strata, vars::Vector{S}; 
        binvars = S[ ], catvars = S[ ], npvars = S[ ], 
        addnmissing = true, addtotal = false, includemissingintotal = false, 
        pvalues = false, kwargs...
    ) where S 
    stratanames = collect(skipmissing(unique(getproperty(data, strata))))       
    strataids = Dict{Symbol}{Vector{Int}}()
    table1 = DataFrame()
    insertcols!(table1, :variablenames => [ "n" ])
    for sn ∈ stratanames 
        ids = findall(x -> !ismissing(x) && x == sn, getproperty(data, strata))
        n = length(ids)
        insertcols!(table1, Symbol(sn) => [ "$n" ])
        push!(strataids, Symbol(sn) => ids)
    end
    if addtotal || addnmissing 
        if addtotal && includemissingintotal # include all records in the totals column
            push!(strataids, :Total => collect(axes(data, 1)))
        else # only include records where the stratifying variable is not missing
            ids = findall(!ismissing, getproperty(data, strata))
            push!(strataids, :Total => ids)
        end 
        if addtotal 
            ids = strataids[:Total]
            n = length(ids)
            insertcols!(table1, :Total => [ "$n" ]) 
        end
        if addnmissing 
            if addtotal && includemissingintotal 
                # then all records are included in the `Total` column so nothing is missing
                insertcols!(table1, :nmissing => [ "" ]) 
            else 
                ids = findall(ismissing, getproperty(data, strata))
                n = length(ids)
                if n == 0 insertcols!(table1, :nmissing => [ "" ])  
                else      insertcols!(table1, :nmissing => [ "$n" ])
                end
            end
        end
    end
    if pvalues insertcols!(table1, :p => [ "" ]) end
    tableone!(table1, data, strata, stratanames, strataids, vars, binvars, catvars, npvars; 
        addnmissing, addtotal, includemissingintotal, pvalues, kwargs...)
    return table1
end

# In case only one variable is supplied, rather than a vector
tableone(data, strata, var; kwargs...) = tableone(data, strata, [ var ]; kwargs...)

# If `vars` is not supplied, defaults to use all variables in the dataset except strata
function tableone(data, strata; kwargs...)
    alldfvars = Symbol.(names(data))
    t1vars = alldfvars[findall(x -> x != strata, alldfvars)]
    return tableone(data, strata, t1vars; kwargs...)
end

# Variables can be listed as Symbols or Strings, but need to be consistent. Functions 
# to check this consistency and make sure all lists are vectors

function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars, catvars, npvars::S; kwargs...
    ) where S
    tableone!(table1, data, strata, stratanames, strataids, vars, binvars, catvars, [ npvars ]; 
        kwargs...)
end

function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars, catvars::S, npvars::Vector{S}; kwargs...
    ) where S
    tableone!(table1, data, strata, stratanames, strataids, vars, binvars, [ catvars ], npvars; 
        kwargs...)
end

function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars::S, catvars::Vector{S}, npvars::Vector{S}; kwargs...
    ) where S
    tableone!(table1, data, strata, stratanames, strataids, vars, [ binvars ], catvars, npvars; 
        kwargs...)
end

# List all keyword arguments and their defaults here so that unspecified keyword 
# arguments throw an error
function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars::Vector{S}, catvars::Vector{S}, npvars::Vector{S}; 
        addnmissing, addtotal, includemissingintotal, pvalues, #default values for these already supplied
        binvardisplay = nothing, digits = 1, pdigits = 3, varnames = nothing
    ) where S
    _tableone!(table1, data, strata, stratanames, strataids, vars, binvars, catvars, npvars; 
        addnmissing, addtotal, includemissingintotal, binvardisplay, digits, pdigits, pvalues, varnames)
end

function _tableone!(table1, data, strata, stratanames, strataids, vars, binvars, catvars, npvars; 
        kwargs...
    )
    for v ∈ vars
        append!(
            table1, 
            newvariable(data, strata, stratanames, strataids, v, binvars, catvars, npvars; 
                kwargs...)
        )
    end
end

function newvariable(data, strata, stratanames, strataids, v, binvars, catvars, npvars; 
        varnames, kwargs...
    )
    varvect = getproperty(data, v)
    varname = getvarname(v, varnames)
    return newvariable(v, strata, stratanames, strataids, varvect, varname, binvars, catvars, npvars; 
        kwargs...)
end

function newvariable(v, strata, stratanames, strataids, varvect, varname, binvars, catvars, npvars; 
        kwargs...
    )
    if v ∈ catvars 
        return catvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
    elseif v ∈ binvars
        return binvariable(v, strata, stratanames, strataids, varvect, varname; kwargs...)
    elseif v ∈ npvars
        return npvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
    else 
        return autovariable(strata, stratanames, strataids, varvect, varname; kwargs...)
    end
end

function catvariable(strata, stratanames, strataids, varvect, varname; pvalues, kwargs...)
    levels = skipmissing(sort(unique(varvect)))
    if pvalues 
        w = length(stratanames)
        ℓ = length(collect(levels))
        pmatrix = zeros(Int, ℓ, w)
        return _catvariable(strata, stratanames, strataids, varvect, varname, levels, pmatrix; kwargs...)
    else 
        return _catvariable(strata, stratanames, strataids, varvect, varname, levels, nothing; kwargs...)
    end
end

function _catvariable(strata, stratanames, strataids, varvect, varname, levels, pmatrix; 
        addnmissing, addtotal, kwargs...
    )
    _t = DataFrame()
    variablenames::Vector{String} = [ [ varname ]; [ "    $lev" for lev ∈ levels ] ]
    insertcols!(_t, :variablenames => variablenames)
    for (i, sn) ∈ enumerate(stratanames) 
        ids = strataids[Symbol(sn)]
        catvariable!(_t, varvect, levels, ids, sn, pmatrix, i; kwargs...)
    end
    if addtotal 
        ids = strataids[:Total]
        catvariable!(_t, varvect, levels, ids, "Total", nothing, nothing; kwargs...)
    end
    if addnmissing addnmissing!(_t, varvect, strataids) end
    addcatpvalue!(_t, pmatrix; kwargs...)
    return _t
end

function catvariable!(_t::DataFrame, varvect, levels, stratumids, sn, pmatrix, i; kwargs...) 
    estimates::Vector{String} = [ "" ]
    for (j, lev) ∈ enumerate(levels) 
        catvariable!(estimates, varvect, lev, stratumids, pmatrix, i, j; kwargs...)
    end
    insertcols!(_t, Symbol(sn) => estimates)
end

function catvariable!(estimates::Vector{String}, varvect, level, stratumids, pmatrix, i, j; 
        digits, kwargs...
    ) # note that this function is used for both categorical and binary variables
    # find those with non-missing values (this is our denominator)
    @unpack n, denom = catvalues(varvect, level, stratumids)
    catvarpmatrix!(pmatrix, n, i, j)
    pc = 100 * n / denom
    push!(estimates, "$(sprint(show, n)) ($(sprint(show, round(pc; digits))))")
end

function catvalues(varvect, level, stratumids)
    nonmissingids = findall(!ismissing, varvect)
    nonmissingstratumids = findall(x -> x ∈ nonmissingids, stratumids)
    denom = length(nonmissingstratumids)
    levelids = findall(x -> !ismissing(x) && x == level, varvect)
    inclusion = findall(x -> x ∈ levelids, stratumids)
    n = length(inclusion)
    return ( n = n, denom = denom )
end

function binvariable(v, strata, stratanames, strataids, varvect, varname; pvalues, kwargs...)
    if pvalues 
        w = length(stratanames)
        pmatrix = zeros(Int, 2, w)
        return _binvariable(v, strata, stratanames, strataids, varvect, varname, pmatrix; kwargs...)
    else 
        return _binvariable(v, strata, stratanames, strataids, varvect, varname, nothing; kwargs...)
    end
end

function _binvariable(v, strata, stratanames, strataids, varvect, varname, pmatrix; 
        addnmissing, addtotal, binvardisplay, kwargs...
    )
    level = binvariabledisplay(v, varvect, binvardisplay)
    _t = DataFrame()
    variablenames::Vector{String} = [ "$varname: $level" ]
    insertcols!(_t, :variablenames => variablenames)
    for (i, sn) ∈ enumerate(stratanames) 
        ids = strataids[Symbol(sn)]
        binvariable!(_t, varvect, level, ids, sn, pmatrix, i; kwargs...)
    end
    if addtotal 
        ids = strataids[:Total]
        binvariable!(_t, varvect, level, ids, "Total", nothing, nothing; kwargs...)
    end
    if addnmissing addnmissing!(_t, varvect, strataids) end
    addbinpvalue!(_t, pmatrix, stratanames, strataids, varvect, level; kwargs...)
    return _t
end

function binvariable!(_t, varvect, level, stratumids, sn, pmatrix, i; kwargs...)
    estimates::Vector{String} = [ ]
    catvariable!(estimates, varvect, level, stratumids, pmatrix, i, 1; kwargs...)
    insertcols!(_t, Symbol(sn) => estimates)
end

function npvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
    return contvariable(npvariable!, KruskalWallisTest, strata, stratanames, strataids, varvect, "$varname: median [IQR]"; 
        kwargs...
    )
end

function npvariable!(_t, varvect, ids, sn; digits = 1, kwargs...)
    med = median(skipmissing(varvect[ids]))
    iqr = quantile(skipmissing(varvect[ids]), [.25, .75])
    _med = "$(sprint(show, round(med; digits)))" 
    _iqr = "$(sprint(show, round(iqr[1]; digits)))–$(sprint(show, round(iqr[2]; digits)))"
    estimates::Vector{String} = [ "$_med [$_iqr]" ]
    insertcols!(_t, Symbol(sn) => estimates)
end

function meanvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
    return contvariable(meanvariable!, OneWayANOVATest, strata, stratanames, strataids, varvect, "$varname: mean (sd)"; 
        kwargs...
    )
end

function meanvariable!(_t, varvect, ids, sn; digits, kwargs...)
    mn = mean(skipmissing(varvect[ids]))
    sd = std(skipmissing(varvect[ids]))
    _mn = "$(sprint(show, round(mn; digits)))" 
    _sd = "$(sprint(show, round(sd; digits)))"
    estimates::Vector{String} = [ "$_mn ($_sd)" ]
    insertcols!(_t, Symbol(sn) => estimates)
end

function autovariable(strata, stratanames, strataids, varvect::AbstractVector, varname; kwargs...)
    return autovariable(strata, stratanames, strataids, Array(varvect), varname; kwargs...)
end

function autovariable(strata, stratanames, strataids, varvect::Vector{<:Number}, varname; kwargs...)
    return meanvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
end

function autovariable(strata, stratanames, strataids, varvect::Vector{S}, varname; 
        kwargs...
    ) where S <:Union{<:Number, Missing}
    return meanvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
end

function autovariable(strata, stratanames, strataids, varvect::Vector, varname; kwargs...)
    return catvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
end

function contvariable(addfn, pfn, strata, stratanames, strataids, varvect, varname; 
        pvalues, kwargs...
    ) 
    if pvalues pvectors = Vector{Real}[ ]
    else       pvectors = nothing 
    end
    return _contvariable(addfn, pfn, strata, stratanames, strataids, varvect, varname, pvectors; 
        kwargs...) 
end

function _contvariable(addfn, pfn, strata, stratanames, strataids, varvect, varname, pvectors; 
        addnmissing, addtotal, kwargs...
    )
    _t = DataFrame()
    variablenames::Vector{String} = [ varname ]
    insertcols!(_t, :variablenames => variablenames)
    for sn ∈ stratanames 
        ids = strataids[Symbol(sn)]
        contpvectors!(pvectors, collect(skipmissing(varvect[ids])))
        addfn(_t, varvect, ids, sn; kwargs...)
    end
    if addtotal
        ids = strataids[:Total]
        addfn(_t, varvect, ids, "Total"; kwargs...)
    end
    if addnmissing addnmissing!(_t, varvect, strataids) end
    addcontpvalue!(_t, pfn, pvectors; kwargs...)
    return _t
end

getvarname(var, varnames::Nothing) = String(var)

function getvarname(var, varnames::Dict)
    if var ∈ keys(varnames) return varnames[var]
    else                    return String(var)
    end 
end

function addnmissing!(_t, varvect, strataids)
    idmissing = findall(ismissing, varvect)
    vectorcountmissing = findall(x -> x ∈ idmissing, strataids[:Total])
    n = length(vectorcountmissing)
    nmissing = [ "" for _ ∈ axes(_t, 1) ]
    nmissing[1] = sprint(show, n)
    insertcols!(_t, :nmissing => nmissing)
end

binvariabledisplay(v, varvect, binvardisplay::Nothing) = maximum(skipmissing(unique(varvect)))

function binvariabledisplay(v, varvect, binvardisplay::Dict)
    if v ∈ keys(binvardisplay) return binvardisplay[v]
    else                       return maximum(skipmissing(unique(varvect)))
    end 
end

catvarpmatrix!(pmatrix::Nothing, n, i, j) = nothing

catvarpmatrix!(pmatrix::Matrix{<:Integer}, n::Int, i::Int, j::Int) = pmatrix[j, i] = n

contpvectors!(pvectors::Nothing, newvect) = nothing 

contpvectors!(pvectors::Vector, newvect) = push!(pvectors, newvect)

addcatpvalue!(_t, pmatrix::Nothing; kwargs...) = nothing

function addcatpvalue!(_t, pmatrix::Matrix{<:Integer}; kwargs...)
    p = catpvalue(pmatrix)
    addpvalue!(_t, p; kwargs...)
end

addbinpvalue!(_t, pmatrix::Nothing, stratanames, strataids, varvect, level; kwargs...) = nothing

function addbinpvalue!(_t, pmatrix::Matrix{<:Integer}, stratanames, strataids, varvect, level; kwargs...)
    for (i, sn) ∈ enumerate(stratanames) 
        stratumids = strataids[Symbol(sn)]
        @unpack n, denom = catvalues(varvect, level, stratumids)
        pmatrix[2, i] = denom - n
    end
    p = catpvalue(pmatrix)
    addpvalue!(_t, p; kwargs...)
end

addcontpvalue!(_t, func, pvectors::Nothing; kwargs...) = nothing

function addcontpvalue!(_t, func, pvectors; kwargs...)
    p = pvalue(func(pvectors...))
    addpvalue!(_t, p; kwargs...)
end

function addpvalue!(_t, p; pdigits, kwargs...)
    pcol = [ "" for _ ∈ axes(_t, 1) ]
    pcol[1] = "$(sprint(show, round(p; digits = pdigits)))"
    insertcols!(_t, :p => pcol)
end

function catpvalue(pmatrix)
    if size(pmatrix) == ( 2, 2 ) return pvalue(FisherExactTest(pmatrix...)) 
    else                         return pvalue(ChisqTest(pmatrix)) 
    end
end

end # module TableOne
