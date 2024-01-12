
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

@testset "String variable names, 2 digits" begin
    # Note that our package does not currently provide p-values or have the `cramVars`
    # keyword. Also, we select `digits = 2`, which matches the R code for mean (sd)
    # results, but provides greater precision in our table than in the example.
    # We produce the table and compare it to a saved version that has been visually
    # compared to the R output.
    testtable_s2 = tableone(
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
    @testset "Compare column names to test data" begin
        testtable_s2names = names(testtable_s2)
        @testset for i ∈ eachindex(testtable_s2names)
            @test testtable_s2names[i] == tablecolumnnames[i]
        end
    end
    @testset "Compare variable names to test data" begin
        @testset for i ∈ axes(testtable_s2, 1)
            @test testtable_s2.variablenames[i] == variablenames[i]
        end
    end
    @testset "Compare trt = 1 to test data" begin
        @testset for i ∈ axes(testtable_s2, 1)
            @test getproperty(testtable_s2, Symbol("1"))[i] == col1_2[i]
        end
    end
    @testset "Compare trt = 2 to test data" begin
        @testset for i ∈ axes(testtable_s2, 1)
            @test getproperty(testtable_s2, Symbol("2"))[i] == col2_2[i]
        end
    end
end # @testset "String variable names, 2 digits"

@testset "Symbol variable names, 2 digits" begin
    # Note that our package does not currently provide p-values or have the `cramVars`
    # keyword. Also, we select `digits = 2`, which matches the R code for mean (sd)
    # results, but provides greater precision in our table than in the example.
    # We produce the table and compare it to a saved version that has been visually
    # compared to the R output.
    testtable_y2 = tableone(
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
    @testset "Compare column names to test data" begin
        testtable_y2names = names(testtable_y2)
        @testset for i ∈ eachindex(testtable_y2names)
            @test testtable_y2names[i] == tablecolumnnames[i]
        end
    end
    @testset "Compare variable names to test data" begin
        @testset for i ∈ axes(testtable_y2, 1)
            @test testtable_y2.variablenames[i] == variablenames[i]
        end
    end
    @testset "Compare trt = 1 to test data" begin
        @testset for i ∈ axes(testtable_y2, 1)
            @test getproperty(testtable_y2, Symbol("1"))[i] == col1_2[i]
        end
    end
    @testset "Compare trt = 2 to test data" begin
        @testset for i ∈ axes(testtable_y2, 1)
            @test getproperty(testtable_y2, Symbol("2"))[i] == col2_2[i]
        end
    end
end # @testset "Symbol variable names, 2 digits"

@testset "Numbers missing" begin
    # The top row of the table should show the number of records missing the stratification 
    # variable. All subsequent rows should exclude those records and show the numbers 
    # missing the variable described on that row. To test this, we use two separate 
    # datasets, one including all records and one excluding those with the stratification 
    # variable missing. All rows except the top one should be equal.
    trtpresentdata = filter(:trt => x -> !ismissing(x), pbcdata)
    # Difference in size between these is the number with missing :trt
    nmissingtrt = size(pbcdata, 1) - size(trtpresentdata, 1)

    testtable_s2_nm = tableone(
        pbcdata,
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
    @test testtable_s2_nm.nmissing[1] == "$nmissingtrt"
    # Adding number missing should not have changed anything else in the table 
    @testset "Compare column names to test data" begin
        testtable_s2_nmnames = names(testtable_s2_nm)
        @testset for i ∈ eachindex(testtable_s2_nmnames)
            @test testtable_s2_nmnames[i] == tablecolumnnames_nm[i]
        end
    end
    @testset "Compare variable names to test data" begin
        @testset for i ∈ axes(testtable_s2_nm, 1)
            @test testtable_s2_nm.variablenames[i] == variablenames[i]
        end
    end
    @testset "Compare trt = 1 to test data" begin
        @testset for i ∈ axes(testtable_s2_nm, 1)
            @test getproperty(testtable_s2_nm, Symbol("1"))[i] == col1_2[i]
        end
    end
    @testset "Compare trt = 2 to test data" begin
        @testset for i ∈ axes(testtable_s2_nm, 1)
            @test getproperty(testtable_s2_nm, Symbol("2"))[i] == col2_2[i]
        end
    end

    # The table made with trtpresentdata should have no records with missing :trt 
    testtable_pd2_nm = tableone(
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
    @test testtable_pd2_nm.nmissing[1] == ""

    # After the initial row, the two tables should be equal
    for tt ∈ [ testtable_s2_nm, testtable_pd2_nm ] 
        filter!(:variablenames => x -> x != "n", tt) 
    end 
    @testset for col ∈ names(testtable_s2_nm) 
        v_s2nm = getproperty(testtable_s2_nm, col)
        v_pd2nm = getproperty(testtable_pd2_nm, col)
        @testset for i ∈ axes(testtable_s2_nm, 1)
            @test v_s2nm[i] == v_pd2nm[i]
        end
    end
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
        @testset for i ∈ eachindex(modelcol_includemissingintotal)
            @test testtable.Total[i] == modelcol_includemissingintotal[i]
        end
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
        @testset for i ∈ eachindex(modelcol_excludemissingintotal)
            @test testtable.Total[i] == modelcol_excludemissingintotal[i]
        end
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
    @testset for col ∈ names(testtable) 
        v = getproperty(testtable, col)
        mv = getproperty(modelbinvartesttable, col)
        @testset for i ∈ axes(modelbinvartesttable, 1)
            @test v[i] == mv[i]
        end
    end
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
   # @test testtable == modeltesttable2
    @testset for col ∈ names(testtable) 
        v = getproperty(testtable, col)
        mv = getproperty(modeltesttable2, col)
        @testset for i ∈ axes(modeltesttable2, 1)
            @test v[i] == mv[i]
        end
    end
end # @testset "Specified variable names"

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
   # @test testtable == modeltesttable2
    @testset for col ∈ names(testtable) 
        v = getproperty(testtable, col)
        mv = getproperty(modeltesttable2, col)
        @testset for i ∈ axes(modeltesttable2, 1)
            @test v[i] == mv[i]
        end
    end
end # @testset "Specified variable names"

@testset "Identify categorical variables automatically" begin
    
end # @testset "Identify categorical variables automatically" 

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
