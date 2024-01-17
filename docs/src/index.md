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
