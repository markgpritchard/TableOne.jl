var documenterSearchIndex = {"docs":
[{"location":"#TableOne.jl","page":"TableOne.jl","title":"TableOne.jl","text":"","category":"section"},{"location":"","page":"TableOne.jl","title":"TableOne.jl","text":"tableone","category":"page"},{"location":"#TableOne.tableone","page":"TableOne.jl","title":"TableOne.tableone","text":"tableone(data, strata[, vars]; <keyword arguments>)\n\nProduce a summary table which may be used as Table 1 in a manuscript.\n\nArguments\n\ndata: A DataFrame containing the data to be included in the table\nstrata: The variable (a column in data) by which the data should be stratified    in the table\nvars: The variables to be listed in the table, defaults to Symbol.(names(data))    if not supplied\n\nKeyword arguments\n\nTypes of variables\n\nEach of these must be supplied as the same type as vars, e.g. if vars is a Vector{Symbol}      then these should each be a Vector{Symbol}. Variables supplied to one of these      arguments but not the main vars argument will not be displayed.\n\nbinvars: binary variables – variable will take one row and show number (%)    with the selected level (see binvardisplay below)\ncatvars: categorical variables – each level in the variable will be shown on    a separate line with the number (%) in that category\nnpvars: non-parametric variables – will display median [1st–3rd quartiles]\n\nAny variables not included in one of these arguments will be presented as      mean (standard deviation) if the contents of the variable are      <:Union{<:Number, Missing}, and as categorical otherwise.\n\nAdditional keyword arguments\n\naddnmissing = true: include the numer of records with missing values for each    variable. If true, will also display number with missing strata values\naddtotal = false: include a column of totals across all strata\nbinvardisplay = nothing: optionally, a Dict to choose the level to display    for binary values. Any variables not listed will use the value chosen by maximum(skipmissing(.))\nvarnames = nothing: optionally, a Dict of names for variables different    from the column titles in data, of the form Dict(:columnname => \"name to print\").    Any variables not included will be listed by the column name\n\nExamples\n\njulia> using TableOne, CSV, DataFrames, Downloads\n\njulia> # use the public PBC dataset\n\njulia> pbcdata = CSV.read(\n    Downloads.download(\"http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv\"),\n    DataFrame;\n    missingstring = \"NA\")\n[...]\n\njulia> tableone(\n    pbcdata,\n    :trt,\n    [ \"time\", \"status\", \"age\", \"sex\", \"ascites\", \"hepato\", \"spiders\", \"edema\",\n        \"bili\", \"chol\", \"albumin\", \"copper\", \"alk.phos\", \"ast\", \"trig\", \"platelet\",\n        \"protime\", \"stage\" ];\n    binvars = [ \"sex\", \"ascites\", \"hepato\", \"spiders\" ],\n    catvars = [ \"status\", \"edema\", \"stage\" ],\n    nparms = [ \"bili\", \"chol\", \"copper\", \"alk.phos\", \"trig\" ],\n    digits = 2,\n    binvardisplay = Dict(\"sex\" => \"f\"))\n29×4 DataFrame\n Row │ variablenames        1                  2                  nmissing \n     │ String               String             String             String   \n─────┼─────────────────────────────────────────────────────────────────────\n   1 │ n                    158                154                106\n   2 │ time: mean (sd)      2015.62 (1094.12)  1996.86 (1155.93)  0\n   3 │ status                                                     0\n   4 │     0                83 (52.53)         85 (55.19)\n   5 │     1                10 (6.33)          9 (5.84)\n   6 │     2                65 (41.14)         60 (38.96)\n   7 │ age: mean (sd)       51.42 (11.01)      48.58 (9.96)       0\n   8 │ sex: f               137 (86.71)        139 (90.26)        0\n   9 │ ascites: 1           14 (8.86)          10 (6.49)          106\n   10 │ hepato: 1            73 (46.2)          87 (56.49)         106\n   11 │ spiders: 1           45 (28.48)         45 (29.22)         106\n   12 │ edema                                                      0\n   13 │     0.0              132 (83.54)        131 (85.06)\n   14 │     0.5              16 (10.13)         13 (8.44)\n   15 │     1.0              10 (6.33)          10 (6.49)\n   16 │ bili: mean (sd)      2.87 (3.63)        3.65 (5.28)        0\n   17 │ chol: mean (sd)      365.01 (209.54)    373.88 (252.48)    134\n   18 │ albumin: mean (sd)   3.52 (0.44)        3.52 (0.4)         0\n   19 │ copper: mean (sd)    97.64 (90.59)      97.65 (80.49)      108\n   20 │ alk.phos: mean (sd)  2021.3 (2183.44)   1943.01 (2101.69)  106\n   21 │ ast: mean (sd)       120.21 (54.52)     124.97 (58.93)     106\n   22 │ trig: mean (sd)      124.14 (71.54)     125.25 (58.52)     136\n   23 │ platelet: mean (sd)  258.75 (100.32)    265.2 (90.73)      11\n   24 │ protime: mean (sd)   10.65 (0.85)       10.8 (1.14)        2\n   25 │ stage                                                      6\n   26 │     1                12 (7.59)          4 (2.6)\n   27 │     2                35 (22.15)         32 (20.78)\n   28 │     3                56 (35.44)         64 (41.56)\n   29 │     4                55 (34.81)         54 (35.06)\n\n\n\n\n\n","category":"function"}]
}