# TableOne.jl

```@docs
tableone
```

```julia
julia> using DataFrames, Random

julia> Random.seed!(1729)
TaskLocalRNG()

julia> testdata = DataFrame(
       Treatment = [ repeat([ "A" ], 6); repeat([ "B"], 6) ],
       Age = 100 .* rand(12),
       Sex = [ rand() <.5 ? "F" : "M" for _ ∈ 1:12 ],
       Cats = [ rand() < .2 ? "X" : rand() < .7 ? "Y" : "Z" for _ ∈ 1:12 ],
       MissMeasure = [ rand() < .2 ? missing : rand() for _ ∈ 1:12 ])   
12×5 DataFrame
 Row │ Treatment  Age       Sex     Cats    MissMeasure     
     │ String     Float64   String  String  Float64?        
─────┼──────────────────────────────────────────────────────
   1 │ A          93.6723   F       Z             0.0794314
   2 │ A          72.258    F       Z             0.150444
   3 │ A          77.4209   M       Y             0.398768
   4 │ A           6.99781  M       Y             0.862593
   5 │ A          33.7028   M       Y             0.594225
   6 │ A          20.0623   F       Y       missing
   7 │ B          69.1809   M       X             0.674373
   8 │ B          70.8002   M       Y             0.152751
   9 │ B          41.5067   M       Z             0.925468
  10 │ B          90.4592   F       Z             0.130062
  11 │ B          42.1594   M       Y             0.436471
  12 │ B          51.0417   F       Y             0.295702
```

## Categorical variables

Categorical variables are displayed with the name of the variable on one line, then the names of each category on a separate line beneath. Each category displays the number of individuals in that category and the percentage of non-missing within that column. 

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
