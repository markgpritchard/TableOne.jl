
using CategoricalArrays
using DataFrames
using Documenter
using RDatasets
using StableRNGs
using TableOne
using Test

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

pbcdata = dataset("survival", "pbc")

@testset "p-values" begin 
    t1 = tableone(
        testdata, 
        :Sex, 
        [ :Treatment ]; 
        cramvars=:Treatment, npvars=:MissMeasure, 
        addnmissing=false, pvalues=true, addtestname=true
    )

    @testset for (vn, td) ∈ zip(
        [ "variablenames", "M", "F", "p", "test" ], 
        [ t1variablenames, t1_M, t1_F, t1_p, t1_test ]
    )
        vcol = getproperty(t1, Symbol(vn))
        @testset for i ∈ 1:2 
            @test vcol[i] == td[i] 
        end
    end
end

@testset "Categorical arrays" begin
    # Specific `CategoricalArray` functions not needed for binary outcomes. Tests retained to 
    # confirm this.
    hepatocat = DataFrame(
        Hepato = [ 0, 1],
        Hepatocat = CategoricalArray([ "Absent", "Present" ]; ordered=true)
    )
    leftjoin!(pbcdata, hepatocat; on = :Hepato, matchmissing=:notequal)
    levels!(pbcdata.Hepatocat, [ "Absent", "Present" ])

    t2 = tableone(
        pbcdata,
        :Trt,
        [ "Hepato" ];
        addnmissing=false,
        binvars = [ "Hepato" ],
        varnames = Dict(
            "Hepato" => "Hepatomegaly",
        )
    )

    @testset for (vn, td) ∈ zip([ "variablenames", "1", "2" ], [ t2variablenames, t2_1, t2_2 ])
        vcol = getproperty(t2, Symbol(vn))
        @testset for i ∈ 1:2 
            @test vcol[i] == td[i] 
        end
    end

    t3 = tableone(
        pbcdata,
        :Trt,
        [ "Hepato" ];
        addnmissing=false,
        cramvars = [ "Hepato" ],
        varnames = Dict(
            "Hepato" => "Hepatomegaly",
        )
    )

    @testset for (vn, td) ∈ zip([ "variablenames", "1", "2" ], [ t3variablenames, t3_1, t3_2 ])
        vcol = getproperty(t3, Symbol(vn))
        @testset for i ∈ 1:2 
            @test vcol[i] == td[i] 
        end
    end
end

end  # @testset "TableOne.jl" 
