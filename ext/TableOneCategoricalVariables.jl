
module TableOneCategoricalVariables

using TableOne 
using CategoricalArrays

function TableOne.catvariable(strata, stratanames, strataids, varvect::CategoricalArray, varname; kwargs...)
    lvls = levels(varvect)
    return TableOne.catvariable(strata, stratanames, strataids, varvect, varname, lvls; kwargs...)
end
   
end # module TableOneCategoricalVariables
