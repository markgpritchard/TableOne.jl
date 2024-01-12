# TableOne

[![Build Status](https://github.com/markgpritchard/TableOne.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/markgpritchard/TableOne.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/markgpritchard/TableOne.jl/graph/badge.svg?token=2FWXZYCS0I)](https://codecov.io/gh/markgpritchard/TableOne.jl)

Package to produce a summary table which may be used as Table 1 in a manuscript.

# Installation

```julia
julia> using Pkg

julia> Pkg.add("TableOne")

julia> using TableOne
```

# Example use 

The only exported function is `tableone`. Documentation for this function is available at https://markgpritchard.github.io/TableOne.jl/.

We use a publicly available Primary Biliary Cholangitis dataset to create an example Table 1.
```julia
julia> using TableOne, CSV, DataFrames, Downloads

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
        "bili" => "Bilirubin: mg/dL", 
        "chol" => "Cholesterol: mg/dL"
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
   9 │ Bilirubin: mg/dL: median [IQR]    1.4 [0.8–3.2]         1.3 [0.72–3.6]        0
  10 │ Cholesterol: mg/dL: median [IQR]  315.5 [247.75–417.0]  303.5 [254.25–377.0]  28
  11 │ stage                                                                         0
  12 │     1                             12 (7.59)             4 (2.6)
  13 │     2                             35 (22.15)            32 (20.78)
  14 │     3                             56 (35.44)            64 (41.56)
  15 │     4                             55 (34.81)            54 (35.06)
```

# Issues

This package is early in its development. Please list any problems under the *Issues* tab.
