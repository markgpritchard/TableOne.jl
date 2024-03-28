
```@meta
DocTestSetup = quote
    using DataFrames
    using StableRNGs 

    ENV["COLUMNS"] = 100
end
```

# TableOne.jl

This package is designed to summarize a dataset, for example information about participants 
    in a study as may be needed for *Table 1* of a manuscript. It exports one function, 
    `tableone`.

```@docs
tableone
```

## Detailed examples of usage 

### Mock dataset for examples 

We create this dataset to use in the following examples.

```jldoctest label
julia> using DataFrames, StableRNGs

julia> rng = StableRNG(1729)
StableRNGs.LehmerRNG(state=0x00000000000000000000000000000d83)

julia> testdata = DataFrame(
              Treatment = [ repeat([ "A" ], 6); repeat([ "B"], 6) ],
              Age = 100 .* rand(rng, 12),
              Sex = [ rand(rng) <.5 ? "F" : "M" for _ ∈ 1:12 ],
              Cats = [ rand(rng) < .2 ? "X" : rand(rng) < .6 ? "Y" : "Z" for _ ∈ 1:12 ],
              MissCats = [ rand(rng) < .3 ? missing : rand(rng) < .4 ? "U" : "V" for _ ∈ 1:12 ],
              MissMeasure = [ rand(rng) < .2 ? missing : rand(rng) for _ ∈ 1:12 ])
12×6 DataFrame
 Row │ Treatment  Age        Sex     Cats    MissCats  MissMeasure    
     │ String     Float64    String  String  String?   Float64?       
─────┼────────────────────────────────────────────────────────────────
   1 │ A          72.9422    M       Y       missing         0.292097
   2 │ A          17.0639    F       Y       V               0.297467
   3 │ A          27.2361    F       Z       missing         0.572896
   4 │ A          37.168     M       X       U               0.722079
   5 │ A           1.62378   M       X       missing         0.805181
   6 │ A          84.4942    F       X       U         missing        
   7 │ B          26.5527    F       Y       missing   missing        
   8 │ B          12.8692    M       Y       V               0.611862
   9 │ B          56.0895    M       Z       V               0.463648
  10 │ B           0.951134  M       Y       V               0.187837
  11 │ B          13.334     M       Y       V               0.770172
  12 │ B          85.8527    F       Z       V               0.552469
```

### Selecting variables for the table 

`tableone` takes three positional arguments: `data`, `strata` and `vars`. If only 
    `data` is supplied then all variables are summarized.

```jldoctest label
julia> using TableOne

julia> tableone(testdata)
16×3 DataFrame
 Row │ variablenames           Total        nmissing 
     │ String                  String       String   
─────┼───────────────────────────────────────────────
   1 │ n                       12
   2 │ Treatment                            0
   3 │     A                   6 (50.0)
   4 │     B                   6 (50.0)
   5 │ Age: mean (sd)          36.3 (31.0)  0
   6 │ Sex                                  0
   7 │     F                   5 (41.7)
   8 │     M                   7 (58.3)
   9 │ Cats                                 0
  10 │     X                   3 (25.0)
  11 │     Y                   6 (50.0)
  12 │     Z                   3 (25.0)
  13 │ MissCats                             4
  14 │     U                   2 (25.0)
  15 │     V                   6 (75.0)
  16 │ MissMeasure: mean (sd)  0.5 (0.2)    2
```

This is equivalent to providing all variables in order.

```jldoctest label
julia> tableone(testdata, [ :Treatment, :Age, :Sex, :Cats, :MissCats, :MissMeasure ]) == tableone(testdata)
true
```

To change the order of variables and change the order they are displayed, pass a Vector of 
    variable names as Strings or Symbols.

```jldoctest label
julia> tableone(testdata, [ :Sex, :Age ])
5×3 DataFrame
 Row │ variablenames   Total        nmissing 
     │ String          String       String   
─────┼───────────────────────────────────────
   1 │ n               12
   2 │ Sex                          0
   3 │     F           5 (41.7)
   4 │     M           7 (58.3)
   5 │ Age: mean (sd)  36.3 (31.0)  0

julia> tableone(testdata, [ "Cats" ])
5×3 DataFrame
 Row │ variablenames  Total     nmissing 
     │ String         String    String   
─────┼───────────────────────────────────
   1 │ n              12
   2 │ Cats                     0
   3 │     X          3 (25.0)
   4 │     Y          6 (50.0)
   5 │     Z          3 (25.0)
```

Note that if you provide a single variable as a String or Symbol, rather than as a Vector, 
    it will be interpretted as the stratification variable.

```jldoctest label
julia> tableone(testdata, :Cats)
12×5 DataFrame
 Row │ variablenames           Y            Z            X            nmissing 
     │ String                  String       String       String       String   
─────┼─────────────────────────────────────────────────────────────────────────
   1 │ n                       6            3            3
   2 │ Treatment                                                      0
   3 │     A                   2 (33.3)     1 (33.3)     3 (100.0)
   4 │     B                   4 (66.7)     2 (66.7)     0 (0.0)
   5 │ Age: mean (sd)          24.0 (25.4)  56.4 (29.3)  41.1 (41.6)  0
   6 │ Sex                                                            0
   7 │     F                   2 (33.3)     2 (66.7)     1 (33.3)
   8 │     M                   4 (66.7)     1 (33.3)     2 (66.7)
   9 │ MissCats                                                       4
  10 │     U                   0 (0.0)      0 (0.0)      2 (100.0)
  11 │     V                   4 (100.0)    2 (100.0)    0 (0.0)
  12 │ MissMeasure: mean (sd)  0.4 (0.2)    0.5 (0.1)    0.8 (0.1)    2
```

Variables are automatically classified according to the data found in them. These can also 
    be specified with keyword arguments`binvars`, `catvars`, `npvars`, `paramvars` and 
    `cramvars`. These can be supplied with a vector of variable names or instead of one. 

```jldoctest label
julia> tableone(testdata, [ :Treatment, :Age ]; npvars=:Age)
5×3 DataFrame
 Row │ variablenames      Total             nmissing 
     │ String             String            String   
─────┼───────────────────────────────────────────────
   1 │ n                  12
   2 │ Treatment                            0
   3 │     A              6 (50.0)
   4 │     B              6 (50.0)
   5 │ Age: median [IQR]  26.9 [13.2–60.3]  0

julia> tableone(testdata; binvars=:Treatment, paramvars=:Age)
3×3 DataFrame
 Row │ variablenames   Total        nmissing 
     │ String          String       String   
─────┼───────────────────────────────────────
   1 │ n               12
   2 │ Treatment: B    6 (50.0)     0
   3 │ Age: mean (sd)  36.3 (31.0)  0

julia> tableone(testdata; cramvars=[:Treatment ])
2×3 DataFrame
 Row │ variablenames   Total            nmissing 
     │ String          String           String   
─────┼───────────────────────────────────────────
   1 │ n               12
   2 │ Treatment: A/B  6/6 (50.0/50.0)  0
```

Note that if you are combining the positional `vars` argument and the keyword arguments, any 
    variables not included in `vars` will be omitted from the table. 

```jldoctest label
julia> tableone(testdata, [ :Treatment, :Age ]; npvars=:MissMeasure)
5×3 DataFrame
 Row │ variablenames   Total        nmissing 
     │ String          String       String   
─────┼───────────────────────────────────────
   1 │ n               12
   2 │ Treatment                    0
   3 │     A           6 (50.0)
   4 │     B           6 (50.0)
   5 │ Age: mean (sd)  36.3 (31.0)  0
```

### Stratification variable 

A single stratification variable can be given. As above, if no variable list is supplied, 
    all other variables will be included in the table. You can also select which variables 
    you want to include in the table. 

```jldoctest label
julia> tableone(testdata, "Treatment", [ "Age", "Sex" ])
5×4 DataFrame
 Row │ variablenames   A            B            nmissing 
     │ String          String       String       String   
─────┼────────────────────────────────────────────────────
   1 │ n               6            6
   2 │ Age: mean (sd)  40.1 (32.4)  32.6 (32.2)  0
   3 │ Sex                                       0
   4 │     F           3 (50.0)     2 (33.3)
   5 │     M           3 (50.0)     4 (66.7)

julia> tableone(testdata, :Treatment, :Treatment)
4×4 DataFrame
 Row │ variablenames  A          B          nmissing 
     │ String         String     String     String   
─────┼───────────────────────────────────────────────
   1 │ n              6          6
   2 │ Treatment                            0
   3 │     A          6 (100.0)  0 (0.0)
   4 │     B          0 (0.0)    6 (100.0)
```

Totals are displayed with the `addtotal` argument 

```jldoctest label
julia> tableone(testdata, "Treatment", [ "Age", "Sex" ]; paramvars="Age", addtotal=true)
5×5 DataFrame
 Row │ variablenames   A            B            Total        nmissing 
     │ String          String       String       String       String   
─────┼─────────────────────────────────────────────────────────────────
   1 │ n               6            6            12
   2 │ Age: mean (sd)  40.1 (32.4)  32.6 (32.2)  36.3 (31.0)  0
   3 │ Sex                                                    0
   4 │     F           3 (50.0)     2 (33.3)     5 (41.7)
   5 │     M           3 (50.0)     4 (66.7)     7 (58.3)
```

Using default settings, any individual missing values in the stratification variable 
    are listed in the *n* row, then are omited from the remainder of the table.

```jldoctest label
julia> tableone(testdata, :MissCats, [ :Sex, :MissMeasure ])      
5×4 DataFrame
 Row │ variablenames           V          U          nmissing 
     │ String                  String     String     String   
─────┼────────────────────────────────────────────────────────
   1 │ n                       6          2          4
   2 │ Sex                                           0
   3 │     F                   2 (33.3)   1 (50.0)
   4 │     M                   4 (66.7)   1 (50.0)
   5 │ MissMeasure: mean (sd)  0.5 (0.2)  0.7 (NaN)  1
```

### P-values 

P-values to compare between the stratification levels can be calculated automatically. Users 
    are advised to ensure they are happy with the methods used and the values calculated.
    The method being used depends on the type of variable supplied. It is displayed by 
    selecting `addtestname=true`.

```jldoctest label; filter = r"\@.*73"
julia> tableone(
           testdata, 
           :Sex, 
           [ :Treatment, :Age, :Cats, :MissCats, :MissMeasure ]; 
           binvars=:Treatment, npvars=:MissMeasure, 
           addnmissing=false, pvalues=true, addtestname=true
       )
┌ Warning: This test is only asymptotically correct and might be inaccurate for the given group size
└ @ HypothesisTests yourpath.jl:73
11×5 DataFrame
 Row │ variablenames              M              F              p       test
     │ String                     String         String         String  String
─────┼────────────────────────────────────────────────────────────────────────────────────
   1 │ n                          7              5
   2 │ Treatment: B               4 (57.1)       2 (40.0)       1.0     FisherExactTest
   3 │ Age: mean (sd)             27.9 (28.2)    48.2 (34.0)    0.276   OneWayANOVATest
   4 │ Cats                                                     0.598   ChisqTest
   5 │     X                      2 (28.6)       1 (20.0)
   6 │     Y                      4 (57.1)       2 (40.0)
   7 │     Z                      1 (14.3)       2 (40.0)
   8 │ MissCats                                                 1.0     FisherExactTest
   9 │     U                      1 (20.0)       1 (33.3)
  10 │     V                      4 (80.0)       2 (66.7)
  11 │ MissMeasure: median [IQR]  0.6 [0.4–0.7]  0.6 [0.4–0.6]  0.569   KruskalWallisTest
```

## Categorical variables

Categorical variables are displayed with the name of the variable on one line, then the 
    names of each category on a separate line beneath. Each category displays the number of 
    individuals in that category and the percentage of non-missing within that column. 

If a column in the data is formatted as a `CategoricalArray` then the levels in 
    that array will be shown in Table 1 as ordered in the array.

```jldoctest label
julia> using CategoricalArrays, CSV, Downloads 

julia> url = "http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv";

julia> pbcdata = CSV.read(Downloads.download(url), DataFrame; missingstring = "NA");

julia> edemaconversion = DataFrame(
       edema = [ 0, 0.5, 1 ],
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

julia> leftjoin!(pbcdata, edemaconversion; on = :edema);

julia> levels!(
           pbcdata.edemalevel, 
           [ "No edema", "Untreated or successfully treated", "Unsuccessfully treated" ]
       );

julia> tableone(
           pbcdata,
           :trt,
           [ "age", "sex", "hepato", "edemalevel", "bili", "chol", "stage" ];
           addnmissing=false,
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
15×3 DataFrame
 Row │ variablenames                      1                     2
     │ String                             String                String
─────┼───────────────────────────────────────────────────────────────────────────────
   1 │ n                                  158                   154
   2 │ Age, years: mean (sd)              51.42 (11.01)         48.58 (9.96)
   3 │ sex: f                             137 (86.71)           139 (90.26)
   4 │ Hepatomegaly: 1                    73 (46.2)             87 (56.49)
   5 │ edemalevel
   6 │     No edema                       132 (83.54)           131 (85.06)
   7 │     Untreated or successfully tr…  16 (10.13)            13 (8.44)
   8 │     Unsuccessfully treated         10 (6.33)             10 (6.49)
   9 │ Bilirubin, mg/dL: median [IQR]     1.4 [0.8–3.2]         1.3 [0.72–3.6]
  10 │ Cholesterol, mg/dL: median [IQR]   315.5 [247.75–417.0]  303.5 [254.25–377.0]
  11 │ stage
  12 │     1                              12 (7.59)             4 (2.6)
  13 │     2                              35 (22.15)            32 (20.78)
  14 │     3                              56 (35.44)            64 (41.56)
  15 │     4                              55 (34.81)            54 (35.06)
```
