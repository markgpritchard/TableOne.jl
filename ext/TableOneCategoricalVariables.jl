
module TableOneCategoricalVariables

using TableOne 
using CategoricalArrays

TableOne.binvariabledisplay(v, varvect::CategoricalArray, binvardisplay::Nothing) = maximum(varvect)

function TableOne.catvariable(strata, stratanames, strataids, varvect::CategoricalArray, varname; kwargs...)
    lvls = levels(varvect)
    return TableOne.catvariable(strata, stratanames, strataids, varvect, varname, lvls; kwargs...)
end
   
end # module TableOneCategoricalVariables
