
module TableOne

using DataFrames, StatsBase

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
    [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema",
        "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet",
        "protime", "stage" ];
    binvars = [ "sex", "ascites", "hepato", "spiders" ],
    catvars = [ "status", "edema", "stage" ],
    nparms = [ "bili", "chol", "copper", "alk.phos", "trig" ],
    digits = 2,
    binvardisplay = Dict("sex" => "f"))
29×4 DataFrame
 Row │ variablenames        1                  2                  nmissing 
     │ String               String             String             String   
─────┼─────────────────────────────────────────────────────────────────────
   1 │ n                    158                154                106
   2 │ time: mean (sd)      2015.62 (1094.12)  1996.86 (1155.93)  0
   3 │ status                                                     0
   4 │     0                83 (52.53)         85 (55.19)
   5 │     1                10 (6.33)          9 (5.84)
   6 │     2                65 (41.14)         60 (38.96)
   7 │ age: mean (sd)       51.42 (11.01)      48.58 (9.96)       0
   8 │ sex: f               137 (86.71)        139 (90.26)        0
   9 │ ascites: 1           14 (8.86)          10 (6.49)          106
   10 │ hepato: 1            73 (46.2)          87 (56.49)         106
   11 │ spiders: 1           45 (28.48)         45 (29.22)         106
   12 │ edema                                                      0
   13 │     0.0              132 (83.54)        131 (85.06)
   14 │     0.5              16 (10.13)         13 (8.44)
   15 │     1.0              10 (6.33)          10 (6.49)
   16 │ bili: mean (sd)      2.87 (3.63)        3.65 (5.28)        0
   17 │ chol: mean (sd)      365.01 (209.54)    373.88 (252.48)    134
   18 │ albumin: mean (sd)   3.52 (0.44)        3.52 (0.4)         0
   19 │ copper: mean (sd)    97.64 (90.59)      97.65 (80.49)      108
   20 │ alk.phos: mean (sd)  2021.3 (2183.44)   1943.01 (2101.69)  106
   21 │ ast: mean (sd)       120.21 (54.52)     124.97 (58.93)     106
   22 │ trig: mean (sd)      124.14 (71.54)     125.25 (58.52)     136
   23 │ platelet: mean (sd)  258.75 (100.32)    265.2 (90.73)      11
   24 │ protime: mean (sd)   10.65 (0.85)       10.8 (1.14)        2
   25 │ stage                                                      6
   26 │     1                12 (7.59)          4 (2.6)
   27 │     2                35 (22.15)         32 (20.78)
   28 │     3                56 (35.44)         64 (41.56)
   29 │     4                55 (34.81)         54 (35.06)
```
"""
function tableone(data, strata, vars::Vector{S}; 
        binvars = S[ ], catvars = S[ ], npvars = S[ ], 
        addnmissing = true, addtotal = false, kwargs...
    ) where S 
    stratanames = unique(getproperty(data, strata))
    strataids = Dict{Symbol}{Vector{Int}}()
    table1 = DataFrame()
    insertcols!(table1, :variablenames => [ "n" ])
    for sn ∈ stratanames 
        ismissing(sn) && continue
        ids = findall(x -> !ismissing(x) && x == sn, getproperty(data, strata))
        n = length(ids)
        insertcols!(table1, Symbol(sn) => [ "$n" ])
        push!(strataids, Symbol(sn) => ids)
    end
    if addtotal 
        ids = findall(!ismissing, getproperty(data, strata))
        n = length(ids)
        insertcols!(table1, :Total => [ "$n" ]) 
        push!(strataids, :Total => ids)
    end
    if addnmissing 
        ids = findall(ismissing, getproperty(data, strata))
        n = length(ids)
        if n == 0 insertcols!(table1, :nmissing => [ "" ])  
        else      insertcols!(table1, :nmissing => [ "$n" ])
        end
    end
    tableone!(table1, data, strata, stratanames, strataids, vars, binvars, catvars, npvars; 
        addnmissing, addtotal, kwargs...)
    return table1
end

# In case only one variable is supplied, rather than a vector
tableone(data, strata, var; kwargs...) = tableone(data, strata, [ var ]; kwargs...)

# If `vars` is not supplied, defaults to use all variables in the dataset
tableone(data, strata; kwargs...) = tableone(data, strata, Symbol.(names(data)); kwargs...)

# Variables can be listed as Symbols or Strings, but need to be consistent. Functions 
# to check this consistency and make sure all lists are vectors

function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars, catvars, npvars::S; kwargs...
    ) where S
    return tableone!(table1, data, strata, stratanames, strataids, vars, binvars, catvars, [ npvars ]; 
        kwargs...)
end

function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars, catvars::S, npvars::Vector{S}; kwargs...
    ) where S
    return tableone!(table1, data, strata, stratanames, strataids, vars, binvars, [ catvars ], npvars; 
        kwargs...)
end

function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars::S, catvars::Vector{S}, npvars::Vector{S}; kwargs...
    ) where S
    return tableone!(table1, data, strata, stratanames, strataids, vars, [ binvars ], catvars, npvars; 
        kwargs...)
end

function tableone!(table1, data, strata, stratanames, strataids, vars::Vector{S}, 
        binvars::Vector{S}, catvars::Vector{S}, npvars::Vector{S}; kwargs...
    ) where S
    for v ∈ vars
        append!(
            table1, 
            newvariable(data, strata, stratanames, strataids, v, binvars, catvars, npvars; 
                kwargs...)
        )
    end
end

function newvariable(data, strata, stratanames, strataids, v, binvars, catvars, npvars; 
        varnames = nothing, kwargs...
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

function catvariable(strata, stratanames, strataids, varvect, varname; 
        addnmissing, addtotal, kwargs...
    )
    levels = skipmissing(sort(unique(varvect)))
    _t = DataFrame()
    variablenames::Vector{String} = [ [ varname ]; [ "    $lev" for lev ∈ levels ] ]
    insertcols!(_t, :variablenames => variablenames)
    for sn ∈ stratanames 
        ismissing(sn) && continue
        ids = strataids[Symbol(sn)]
        catvariable!(_t, varvect, levels, ids, sn; kwargs...)
    end
    if addtotal 
        ids = strataids[:Total]
        catvariable!(_t, varvect, levels, ids, "Total"; kwargs...)
    end
    if addnmissing addnmissing!(_t, varvect) end
    return _t
end

function catvariable!(_t::DataFrame, varvect, levels, stratumids, sn; kwargs...) 
    estimates::Vector{String} = [ "" ]
    total = length(stratumids)
    for lev ∈ levels 
        catvariable!(estimates, varvect, lev, stratumids, total; kwargs...)
    end
    insertcols!(_t, Symbol(sn) => estimates)
end

function catvariable!(estimates::Vector{String}, varvect, level, stratumids, total::Int; 
        digits = 1, kwargs...
    )
    levelids = findall(x -> !ismissing(x) && x == level, varvect)
    inclusion = findall(x -> x ∈ levelids, stratumids)
    n = length(inclusion)
    pc = 100 * n / total
    push!(estimates, "$(sprint(show, n)) ($(sprint(show, round(pc; digits))))")
end

function binvariable(v, strata, stratanames, strataids, varvect, varname; 
        addnmissing, addtotal, varnames = nothing, binvardisplay = nothing, kwargs...
    )
    level = binvariabledisplay(v, varvect, binvardisplay)
    _t = DataFrame()
    variablenames::Vector{String} = [ "$varname: $level" ]
    insertcols!(_t, :variablenames => variablenames)
    for sn ∈ stratanames 
        ismissing(sn) && continue
        ids = strataids[Symbol(sn)]
        binvariable!(_t, varvect, level, ids, sn; kwargs...)
    end
    if addtotal 
        ids = strataids[:Total]
        binvariable!(_t, varvect, level, ids, "Total"; kwargs...)
    end
    if addnmissing addnmissing!(_t, varvect) end
    return _t
end

function binvariable!(_t, varvect, level, stratumids, sn; kwargs...)
    estimates::Vector{String} = [ ]
    total = length(stratumids)
    catvariable!(estimates, varvect, level, stratumids, total; kwargs...)
    insertcols!(_t, Symbol(sn) => estimates)
end

function npvariable(strata, stratanames, strataids, varvect, varname; kwargs...)
    return contvariable(npvariable!, strata, stratanames, strataids, varvect, "$varname: median [IQR]"; 
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
    return contvariable(meanvariable!, strata, stratanames, strataids, varvect, "$varname: mean (sd)"; 
        kwargs...
    )
end

function meanvariable!(_t, varvect, ids, sn; digits = 1, kwargs...)
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

function contvariable(addfn, strata, stratanames, strataids, varvect, varname; 
        addnmissing, addtotal, varnames = nothing, kwargs...
    )
    _t = DataFrame()
    variablenames::Vector{String} = [ varname ]
    insertcols!(_t, :variablenames => variablenames)
    for sn ∈ stratanames 
        ismissing(sn) && continue
        ids = strataids[Symbol(sn)]
        addfn(_t, varvect, ids, sn; kwargs...)
    end
    if addtotal
        ids = strataids[:Total]
        addfn(_t, varvect, ids, "Total"; kwargs...)
    end
    if addnmissing addnmissing!(_t, varvect) end
    return _t
end

getvarname(var, varnames::Nothing) = String(var)

function getvarname(var, varnames::Dict)
    if var ∈ keys(varnames) return varnames[var]
    else                    return String(var)
    end 
end

function addnmissing!(_t, varvect)
    n = length(findall(ismissing, varvect))
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

end # module TableOne
