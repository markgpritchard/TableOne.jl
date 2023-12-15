
using TableOne
using Test
using CSV, DataFrames, Downloads

@testset "TableOne.jl" begin

@testset "Whole table" begin
    # Use the publicly available PBC dataset to reproduce the table produced in R 
    # using CreateTableOne at
    # https://www.rdocumentation.org/packages/tableone/versions/0.13.2/topics/CreateTableOne
    # Note that our package does not currently provide p-values or have the `cramVars`
    # keyword. Also, we select `digits = 2`, which matches the R code for mean (sd)
    # results, but provides greater precision in our table than in the example.
    # We produce the table and compare it to a saved version that has been visually
    # compared to the R output.
    pbcdata = CSV.read(
        Downloads.download("http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv"),
        DataFrame; 
        missingstring = "NA"
    )

    # The saved version is modeltesttable in "modeldataframe.jl"
    include("modeldataframe.jl")
    
    testtable = tableone(
        pbcdata,
        :trt,
        [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema", 
            "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet", 
            "protime", "stage" ];
        binvars = [ "sex", "ascites", "hepato", "spiders" ], 
        catvars = [ "status", "edema", "stage" ], 
        nparms = [ "bili", "chol", "copper", "alk.phos", "trig" ], 
        digits = 2, 
        binvardisplay = Dict("sex" => "f")
    )
    # and a version using Symbols
    testtable2 = tableone(
        pbcdata,
        :trt,
        [ :time, :status, :age, :sex, :ascites, :hepato, :spiders, :edema, 
            :bili, :chol, :albumin, :copper, Symbol("alk.phos"), :ast, :trig, :platelet, 
            :protime, :stage ];
        binvars = [ :sex, :ascites, :hepato, :spiders ], 
        catvars = [ :status, :edema, :stage ], 
        nparms = [ :bili, :chol, :copper, Symbol("alk.phos"), :trig ], 
        digits = 2, 
        binvardisplay = Dict(:sex => "f")
    )  
    @test testtable == testtable2
    @test testtable == modeltesttable
end

end # @testset "TableOne.jl"
