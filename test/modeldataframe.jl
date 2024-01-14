
tablecolumnnames = [ "variablenames", "1", "2" ]

variablenames = [  
    "n",
    "time: mean (sd)",
    "status",
    "    0",
    "    1",
    "    2",
    "age: mean (sd)",
    "sex: f",
    "ascites: 1",
    "hepato: 1",
    "spiders: 1",
    "edema",
    "    0.0",
    "    0.5",
    "    1.0",
    "bili: median [IQR]",
    "chol: median [IQR]",
    "albumin: mean (sd)",
    "copper: median [IQR]",
    "alk.phos: median [IQR]",
    "ast: mean (sd)",
    "trig: median [IQR]",
    "platelet: mean (sd)",
    "protime: mean (sd)",
    "stage",
    "    1",
    "    2",
    "    3",
    "    4" 
]
col1_2 = [
    "158",
    "2015.62 (1094.12)",
    "",
    "83 (52.53)",
    "10 (6.33)",
    "65 (41.14)",
    "51.42 (11.01)",
    "137 (86.71)",
    "14 (8.86)",
    "73 (46.2)",
    "45 (28.48)",
    "",
    "132 (83.54)",
    "16 (10.13)",
    "10 (6.33)",
    "1.4 [0.8–3.2]",
    "315.5 [247.75–417.0]",
    "3.52 (0.44)",
    "73.0 [40.0–121.0]",
    "1214.5 [840.75–2028.0]",
    "120.21 (54.52)",
    "106.0 [84.5–146.0]",
    "258.75 (100.32)",
    "10.65 (0.85)",
    "",
    "12 (7.59)",
    "35 (22.15)",
    "56 (35.44)",
    "55 (34.81)"
]
col2_2 = [
    "154",
    "1996.86 (1155.93)",
    "",
    "85 (55.19)",
    "9 (5.84)",
    "60 (38.96)",
    "48.58 (9.96)",
    "139 (90.26)",
    "10 (6.49)",
    "87 (56.49)",
    "45 (29.22)",
    "",
    "131 (85.06)",
    "13 (8.44)",
    "10 (6.49)",
    "1.3 [0.72–3.6]",
    "303.5 [254.25–377.0]",
    "3.52 (0.4)",
    "73.0 [43.0–139.0]",
    "1283.0 [922.5–1949.75]",
    "124.97 (58.93)",
    "113.0 [84.5–155.0]",
    "265.2 (90.73)",
    "10.8 (1.14)",
    "",
    "4 (2.6)",
    "32 (20.78)",
    "64 (41.56)",
    "54 (35.06)"
]

modeltesttable = DataFrame([
        :variablenames => variablenames,
        Symbol(1) => col1_2,
        Symbol(2) => col2_2
    ])

tablecolumnnames_nm = [ "variablenames", "1", "2", "nmissing" ]



modeltesttable2 = let 
    df = deepcopy(modeltesttable)
    select!(df, Not(:variablenames))
    insertcols!(
        df, 
        1,
        :variablenames => [
            "n",
            "time: mean (sd)",
            "status",
            "    0",
            "    1",
            "    2",
            "Age, years: mean (sd)",
            "sex: f",
            "ascites: 1",
            "Hepatomegaly: 1",
            "spiders: 1",
            "edema",
            "    0.0",
            "    0.5",
            "    1.0",
            "bili: median [IQR]",
            "chol: median [IQR]",
            "albumin: mean (sd)",
            "copper: median [IQR]",
            "alkaline phosphotase: median [IQR]",
            "ast: mean (sd)",
            "trig: median [IQR]",
            "platelet: mean (sd)",
            "protime: mean (sd)",
            "Histologic stage",
            "    1",
            "    2",
            "    3",
            "    4"
        ]
    )
    df
end

modelbinvartesttable = let 
    vn = [ "n", "sex: m" ]
    col1 = [ "158", "21 (13.29)" ]
    col2 = [ "154", "15 (9.74)" ]
    DataFrame([
        :variablenames => vn,
        Symbol(1) => col1,
        Symbol(2) => col2
    ])
end

modelcol_includemissingintotal = [
    "418", 
    "1917.78 (1104.67)", 
    "", 
    "232 (55.5)", 
    "25 (5.98)", 
    "161 (38.52)", 
    "50.74 (10.45)", 
    "374 (89.47)", 
    "24 (7.69)", 
    "160 (51.28)", 
    "90 (28.85)", 
    "", 
    "354 (84.69)", 
    "44 (10.53)", 
    "20 (4.78)", 
    "1.4 [0.8–3.4]", 
    "309.5 [249.5–400.0]", 
    "3.5 (0.42)", 
    "73.0 [41.25–123.0]", 
    "1259.0 [871.5–1980.0]", 
    "122.56 (56.7)", 
    "108.0 [84.25–151.0]", 
    "257.02 (98.33)", 
    "10.73 (1.02)", 
    "", 
    "21 (5.1)", 
    "92 (22.33)", 
    "155 (37.62)", 
    "144 (34.95)"
]

modelcol_excludemissingintotal = [
    "312", 
    "2006.36 (1123.28)", 
    "", 
    "168 (53.85)", 
    "19 (6.09)", 
    "125 (40.06)", 
    "50.02 (10.58)", 
    "276 (88.46)", 
    "24 (7.69)", 
    "160 (51.28)", 
    "90 (28.85)", 
    "", 
    "263 (84.29)", 
    "29 (9.29)", 
    "20 (6.41)", 
    "1.35 [0.8–3.42]", 
    "309.5 [249.5–400.0]", 
    "3.52 (0.42)", 
    "73.0 [41.25–123.0]", 
    "1259.0 [871.5–1980.0]", 
    "122.56 (56.7)", 
    "108.0 [84.25–151.0]", 
    "261.94 (95.61)", 
    "10.73 (1.0)", 
    "", 
    "16 (5.13)", 
    "67 (21.47)", 
    "120 (38.46)", 
    "109 (34.94)"
]

pvals_r = [
    "",
    "0.883",
    "0.884", 
    "",
    "",
    "",
    "0.018",
    "0.421", 
    "0.567", 
    "0.088",
    "0.985",
    "0.877",
    "",
    "",
    "",
    "0.842",
    "0.544",
    "0.874",
    "0.717",
    "0.812",
    "0.46",
    "0.37",
    "0.555", 
    "0.197",
    "0.205", 
    "",
    "",
    "",
    ""
]

pvals_stable = [
    "",
    "0.883",
    "0.894",
    "",
    "",
    "",
    "0.018",
    "0.422",
    "0.568",
    "0.088",
    "0.984",
    "0.877",
    "",
    "",
    "",
    "0.842",
    "0.544",
    "0.874",
    "0.717",
    "0.812",
    "0.46",
    "0.37",
    "0.554",
    "0.197",
    "0.201",
    "",
    "",
    "",
    ""
]
