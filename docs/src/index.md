# TableOne.jl

```@docs
tableone
```

## Use of CategoricalArrays 

If a column in the data is formatted as a `CategoricalArray` then the levels in 
    that array will be shown in Table 1 as ordered in the array.

```julia
using CategoricalArray 

julia> edemaconversion = DataFrame(
       edema = [ 0, .5, 1 ],
       edemalevel = CategoricalArray([ 
            "No edema", 
            "Untreated or successfully treated", 
            "Unsuccessfully treated" ]; 
            ordered = true))
3×2 DataFrame
 Row │ edema    edemalevel
     │ Float64  Cat…
─────┼────────────────────────────────────────────
   1 │     0.0  No edema
   2 │     0.5  Untreated or successfully treated
   3 │     1.0  Unsuccessfully treated

julia> leftjoin!(pbcdata, edemaconversion; on = :edema)

julia> levels!(pbcdata.edemalevel, [ "No edema", "Untreated or successfully treated", "Unsuccessfully treated" ])

julia> tableone(
           pbcdata,
           :trt,
           [ "age", "sex", "hepato", "edemalevel", "bili", "chol", "stage" ];
           binvars = [ "sex", "hepato" ],
           catvars = [ "edemalevel", "stage" ],
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
 Row │ variablenames                      1                     2                     nmissing 
     │ String                             String                String                String   
─────┼─────────────────────────────────────────────────────────────────────────────────────────
   1 │ n                                  158                   154                   106
   2 │ Age, years: mean (sd)              51.42 (11.01)         48.58 (9.96)          0
   3 │ sex: f                             137 (86.71)           139 (90.26)           0
   4 │ Hepatomegaly: 1                    73 (46.2)             87 (56.49)            0
   5 │ edemalevel                                                                     0
   6 │     No edema                       132 (83.54)           131 (85.06)
   7 │     Untreated or successfully tr…  16 (10.13)            13 (8.44)
   8 │     Unsuccessfully treated         10 (6.33)             10 (6.49)
   9 │ Bilirubin, mg/dL: median [IQR]     1.4 [0.8–3.2]         1.3 [0.72–3.6]        0
  10 │ Cholesterol, mg/dL: median [IQR]   315.5 [247.75–417.0]  303.5 [254.25–377.0]  28
  11 │ stage                                                                          0
  12 │     1                              12 (7.59)             4 (2.6)
  13 │     2                              35 (22.15)            32 (20.78)
  14 │     3                              56 (35.44)            64 (41.56)
  15 │     4                              55 (34.81)            54 (35.06)
```
