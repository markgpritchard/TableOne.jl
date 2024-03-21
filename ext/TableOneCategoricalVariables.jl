
module TableOneCategoricalVariables

using TableOne 
using CategoricalArrays

function TableOne._binvariabledisplay(v, varvect::CategoricalArray, binvardisplay::Nothing)
    return maximum(varvect)
end

function TableOne._cramvariable(
    strata, stratanames, strataids, varvect::CategoricalArray, varname; 
    kwargs...
)
    lvls = levels(varvect)
    return TableOne._cramvariable(
        strata, stratanames, strataids, varvect, varname, lvls; 
        kwargs...
    )
end

function TableOne._catvariable(
    strata, stratanames, strataids, varvect::CategoricalArray, varname; 
    kwargs...
)
    lvls = levels(varvect)
    return TableOne._catvariable(
        strata, stratanames, strataids, varvect, varname, lvls; 
        kwargs...
    )
end
   
end # module TableOneCategoricalVariables
