
using TableOne
using Test
using CategoricalArrays, CSV, DataFrames, Downloads, Documenter, StableRNGs

@testset "TableOne.jl" begin

## Follow the code used in the documentation 

Documenter.doctest(TableOne)

## Funtions not currently tested in the documentation 

# Load saved versions that tests compare against
include("modeldataframe.jl")

rng = StableRNG(1729)
testdata = DataFrame(
    Treatment = [ repeat([ "A" ], 6); repeat([ "B"], 6) ],
    Age = 100 .* rand(rng, 12),
    Sex = [ rand(rng) <.5 ? "F" : "M" for _ ∈ 1:12 ],
    Cats = [ rand(rng) < .2 ? "X" : rand(rng) < .6 ? "Y" : "Z" for _ ∈ 1:12 ],
    MissCats = [ rand(rng) < .3 ? missing : rand(rng) < .4 ? "U" : "V" for _ ∈ 1:12 ],
    MissMeasure = [ rand(rng) < .2 ? missing : rand(rng) for _ ∈ 1:12 ]
)

url = "http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv"

pbcdata = CSV.read(Downloads.download(url), DataFrame; missingstring="NA")

@testset "Categorical arrays" begin
    hepatocat = DataFrame(
        hepato = [ 0, 1],
        Hepatocat = CategoricalArray([ "Absent", "Present" ]; ordered=true)
    )
    leftjoin!(pbcdata, hepatocat; on = :hepato, matchmissing=:notequal)
    levels!(pbcdata.Hepatocat, [ "Absent", "Present" ])

    t1 = tableone(
        pbcdata,
        :trt,
        [ "hepato" ];
        addnmissing=false,
        binvars = [ "hepato" ],
        varnames = Dict(
            "hepato" => "Hepatomegaly",
        )
    )

    @testset for (vn, td) ∈ zip([ "variablenames", "1", "2" ], [ t1variablenames, t1_1, t1_2 ])
        vcol = getproperty(t1, Symbol(vn))
        @testset for i ∈ 1:2 
            @test vcol[i] == td[i] 
        end
    end

    t2 = tableone(
        pbcdata,
        :trt,
        [ "hepato" ];
        addnmissing=false,
        cramvars = [ "hepato" ],
        varnames = Dict(
            "hepato" => "Hepatomegaly",
        )
    )

    @testset for (vn, td) ∈ zip([ "variablenames", "1", "2" ], [ t2variablenames, t2_1, t2_2 ])
        vcol = getproperty(t2, Symbol(vn))
        @testset for i ∈ 1:2 
            @test vcol[i] == td[i] 
        end
    end
end

end  # @testset "TableOne.jl" 
