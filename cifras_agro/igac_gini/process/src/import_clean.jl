#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, DataFrames, Tables, CSV, StatsBase, Dates, Arrow, Random, StringEncodings, Transliterate

Random.seed!(19481210)

println("load functions--", now())
function replace_commas(x)
    return [ismissing(item) ? missing : replace(item, "," => ".") for item in x]
end

function coerce_deci(x)
    return [ismissing(item) ? missing : parse(Float64, item) for item in x]
end

println("load data--", now())
input_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/input/GINI_MUNICIPAL_PERCENTILES.csv"

gini_igac = DataFrame(CSV.File(open(input_1, enc"ISO-8859-1")))

println("clean names--", now())
names_gini = names(gini_igac)

names_clean = [
    lowercase(replace(replace(replace(item, " " => "_"), "." => "_"), "__" => "_")) for item in names_gini
    ]

rename!(gini_igac, names_clean)

println("clean values--", now())
n_missng_gini = count(ismissing, gini_igac.gini)

n_missng_area_has = count(ismissing, gini_igac.area_ha)

string_cols = names(gini_igac, String)

transform!(gini_igac, string_cols .=> ByRow(transliterate) .=> string_cols)

cols_numrc = ["area_ha", "gini"]

transform!(gini_igac, cols_numrc .=> replace_commas .=> cols_numrc)

transform!(gini_igac, cols_numrc .=> coerce_deci .=> cols_numrc)

@assert count(ismissing, gini_igac.gini) == n_missng_gini

@assert count(ismissing, gini_igac.area_ha) == n_missng_area_has

println("filter--", now())





