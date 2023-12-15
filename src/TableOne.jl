
module TableOne

using DataFrames, StatsBase

export tableone

"""
    tableone(data, strata[, vars]; <keyword arguments>)

Produce a summary table which may be used as Table 1 in a manuscript.

If `vars` is not supplied, defaults to use all variables in the dataset.
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
