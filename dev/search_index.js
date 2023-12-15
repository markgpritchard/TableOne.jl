var documenterSearchIndex = {"docs":
[{"location":"#TableOne.jl-Documentation","page":"TableOne.jl Documentation","title":"TableOne.jl Documentation","text":"","category":"section"},{"location":"","page":"TableOne.jl Documentation","title":"TableOne.jl Documentation","text":"tableone","category":"page"},{"location":"#TableOne.tableone","page":"TableOne.jl Documentation","title":"TableOne.tableone","text":"tableone(data, strata[, vars]; <keyword arguments>)\n\nProduce a summary table which may be used as Table 1 in a manuscript.\n\nArguments\n\ndata: A DataFrame containing the data to be included in the table\nstrata: The variable (a column in data) by which the data should be stratified    in the table\nvars: The variables to be listed in the table, defaults to Symbol.(names(data))    if not supplied\n\nKeyword arguments\n\nTypes of variables\n\nEach of these must be supplied as the same type as vars, e.g. if vars is a Vector{Symbol}      then these should each be a Vector{Symbol}. Variables supplied to one of these      arguments but not the main vars argument will not be displayed.\n\nbinvars: binary variables – variable will take one row and show number (%)    with the selected level (see binvardisplay below)\ncatvars: categorical variables – each level in the variable will be shown on    a separate line with the number (%) in that category\nnpvars: non-parametric variables – will display median [1st–3rd quartiles]\n\nAny variables not included in one of these arguments will be presented as      mean (standard deviation) if the contents of the variable are      <:Union{<:Number, Missing}, and as categorical otherwise.\n\nAdditional keyword arguments\n\naddnmissing = true: include the numer of records with missing values for each    variable. If true, will also display number with missing strata values\naddtotal = false: include a column of totals across all strata\nbinvardisplay = nothing: optionally, a Dict to choose the level to display    for binary values. Any variables not listed will use the value chosen by maximum(skipmissing(.))\nvarnames = nothing: optionally, a Dict of names for variables different    from the column titles in data, of the form Dict(:columnname => \"name to print\").    Any variables not included will be listed by the column name\n\nExamples\n\njulia> using TableOne, CSV, DataFrames, Downloads\n# use the public PBC dataset\njulia> pbcdata = CSV.read(\n    Downloads.download(\"http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv\"),\n    DataFrame;\n    missingstring = \"NA\")\njulia> tableone(\n    pbcdata,\n    :trt,\n    [ \"time\", \"status\", \"age\", \"sex\", \"ascites\", \"hepato\", \"spiders\", \"edema\",\n        \"bili\", \"chol\", \"albumin\", \"copper\", \"alk.phos\", \"ast\", \"trig\", \"platelet\",\n        \"protime\", \"stage\" ];\n    binvars = [ \"sex\", \"ascites\", \"hepato\", \"spiders\" ],\n    catvars = [ \"status\", \"edema\", \"stage\" ],\n    nparms = [ \"bili\", \"chol\", \"copper\", \"alk.phos\", \"trig\" ],\n    digits = 2,\n    binvardisplay = Dict(\"sex\" => \"f\"))\n\n\n\n\n\n","category":"function"}]
}
