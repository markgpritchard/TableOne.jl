
using TableOne
using Test
using CSV, DataFrames, Downloads

@testset "TableOne.jl" begin

# Use publicly available PBC dataset to reproduce the table produced in R using CreateTableOne at
# https://www.rdocumentation.org/packages/tableone/versions/0.13.2/topics/CreateTableOne
pbcdata = CSV.read(
    Downloads.download("http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv"),
    DataFrame; 
    missingstring = "NA"
)

# Load saved versions that tests compare against
include("modeldataframe.jl")

@testset "Whole table" begin
    # Note that our package does not currently provide p-values or have the `cramVars`
    # keyword. Also, we select `digits = 2`, which matches the R code for mean (sd)
    # results, but provides greater precision in our table than in the example.
    # We produce the table and compare it to a saved version that has been visually
    # compared to the R output.
    testtable = tableone(
        pbcdata,
        :trt,
        [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema", 
            "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet", 
            "protime", "stage" ];
        binvars = [ "sex", "ascites", "hepato", "spiders" ], 
        catvars = [ "status", "edema", "stage" ], 
        npvars = [ "bili", "chol", "copper", "alk.phos", "trig" ], 
        addnmissing = false,
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
        npvars = [ :bili, :chol, :copper, Symbol("alk.phos"), :trig ], 
        addnmissing = false,
        digits = 2, 
        binvardisplay = Dict(:sex => "f")
    )  
    @test testtable == testtable2
    @test testtable == modeltesttable
end # @testset "Whole table"

@testset "Add numbers missing" begin
    # The top row of the table should show the number of records missing the stratification 
    # variable. All subsequent rows should exclude those records and show the numbers 
    # missing the variable described on that row. To test this, we use two separate 
    # datasets, one including all records and one excluding those with the stratification 
    # variable missing. All rows except the top one should be equal.
    totaldata = CSV.read(
        Downloads.download("http://www-eio.upc.edu/~pau/cms/rdata/csv/survival/pbc.csv"),
        DataFrame; 
        missingstring = "NA"
    )
    trtpresentdata = filter(:trt => x -> !ismissing(x), totaldata)
    # Difference in size between these is the number with missing :trt
    nmissingtrt = size(totaldata, 1) - size(trtpresentdata, 1)

    testtable = tableone(
        totaldata,
        :trt,
        [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema", 
            "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet", 
            "protime", "stage" ];
        binvars = [ "sex", "ascites", "hepato", "spiders" ], 
        catvars = [ "status", "edema", "stage" ], 
        npvars = [ "bili", "chol", "copper", "alk.phos", "trig" ], 
        addnmissing = true,
        digits = 2, 
        binvardisplay = Dict("sex" => "f")
    )
    @test testtable.nmissing[1] == "$nmissingtrt"

    # The table made with trtpresentdata should have no records with missing :trt 
    testtable2 = tableone(
        trtpresentdata,
        :trt,
        [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema", 
            "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet", 
            "protime", "stage" ];
        binvars = [ "sex", "ascites", "hepato", "spiders" ], 
        catvars = [ "status", "edema", "stage" ], 
        npvars = [ "bili", "chol", "copper", "alk.phos", "trig" ], 
        addnmissing = true,
        digits = 2, 
        binvardisplay = Dict("sex" => "f")
    )
    @test testtable2.nmissing[1] == ""

    # After the initial row, the two tables should be equal
    for tt ∈ [ testtable, testtable2 ] filter!(:variablenames => x -> x != "n", tt) end 
    @test testtable == testtable2
end # @testset "Add numbers missing"

@testset "Add totals" begin

    @testset "Include missing in total" begin
        # This is not the default option for this function but is the default for 
        # CreateTableOne so we can compare this function's output to that
        testtable = tableone(
            pbcdata,
            :trt,
            [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema",
                "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet",
                "protime", "stage" ];
            binvars = [ "sex", "ascites", "hepato", "spiders" ],
            catvars = [ "status", "edema", "stage" ],
            npvars = [ "bili", "chol", "copper", "alk.phos", "trig" ],
            digits = 2,
            binvardisplay = Dict("sex" => "f"), 
            addtotal = true, 
            includemissingintotal = true
        )
        @test testtable.Total == modelcol_includemissingintotal
    end # @testset "Include missing in total"

    @testset "Exclude missing in total" begin
        # This is our default. We don't currently have an independent reference 
        # for this column so simply test whether it has changed since version 0.1.0. 
        # If it has changed we will need to understand why.
        testtable = tableone(
            pbcdata,
            :trt,
            [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema",
                "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet",
                "protime", "stage" ];
            binvars = [ "sex", "ascites", "hepato", "spiders" ],
            catvars = [ "status", "edema", "stage" ],
            npvars = [ "bili", "chol", "copper", "alk.phos", "trig" ],
            addnmissing = false,
            digits = 2,
            binvardisplay = Dict("sex" => "f"), 
            addtotal = true
        )
        @test testtable.Total == modelcol_excludemissingintotal
    end # @testset "Exclude missing in total"
    
end # @testset "Add totals"

@testset "Binary variable display" begin
    # The `binvardisplay` argument has been used in all other tests so here just 
    # testing the default for sex 
    testtable = tableone(
        pbcdata,
        :trt,
        [ "sex" ];
        binvars = [ "sex" ],
        addnmissing = false,
        digits = 2
    )
    @test testtable == modelbinvartesttable
end # @testset "Binary variable display" 

@testset "Specified variable names" begin
    # specify variable names for variables using `meanvariable`, `binvariable`, 
    # `catvariable` and `npvariable`
    testtable = tableone(
        pbcdata,
        :trt,
        [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema",
            "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet",
            "protime", "stage" ];
        binvars = [ "sex", "ascites", "hepato", "spiders" ],
        catvars = [ "status", "edema", "stage" ],
        npvars = [ "bili", "chol", "copper", "alk.phos", "trig" ],
        addnmissing = false,
        binvardisplay = Dict("sex" => "f"), 
        digits = 2,
        varnames = Dict(
            "age" => "Age, years",
            "hepato" => "Hepatomegaly",
            "stage" => "Histologic stage",
            "alk.phos" => "alkaline phosphotase"
        )
    )
    @test testtable == modeltesttable2
end # @testset "Specified variable names"

@testset "Undefined keywords" begin
    # Any undefined keywords should generate an error
    @test_throws MethodError tableone(
        pbcdata,
        :trt,
        [ "time", "status", "age", "sex", "ascites", "hepato", "spiders", "edema",
            "bili", "chol", "albumin", "copper", "alk.phos", "ast", "trig", "platelet",
            "protime", "stage" ];
        nparms = [ "bili", "chol", "copper", "alk.phos", "trig" ],
    )
end # @testset "Undefined keywords"

end # @testset "TableOne.jl"
