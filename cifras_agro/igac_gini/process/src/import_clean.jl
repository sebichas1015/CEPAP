#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, DataFrames, CSV, Random, Dates, StringEncodings, Transliterate, TidierFiles

Random.seed!(19481210)

println("load functions--", now())
replace_commas(x) = [ismissing(item) ? missing : replace(item, "," => ".") for item in x]
coerce_deci(x) = [ismissing(item) ? missing : parse(Float64, item) for item in x]

println("load data--", now())
input_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/input/GINI_MUNICIPAL_PERCENTILES.csv"
gini_igac = DataFrame(CSV.File(open(input_1, enc"ISO-8859-1")))

println("clean column names--", now())
rename!(gini_igac, Symbol.(replace.(lowercase.(names(gini_igac)), r"\s+|\.+|__+" => "_")))
rename!(gini_igac, replace.(names(gini_igac), "__" => "_"))

println("count missing values--", now())
n_missng_gini = count(ismissing, gini_igac.gini)
n_missng_area_has = count(ismissing, gini_igac.area_ha)

println("clean values--", now())
string_cols = names(gini_igac, String)
transform!(gini_igac, string_cols .=> ByRow(transliterate) .=> string_cols)
cols_numrc = ["area_ha", "gini"]
transform!(gini_igac, cols_numrc .=> (col -> coerce_deci(replace_commas(col))) .=> cols_numrc)
@assert count(ismissing, gini_igac.gini) == n_missng_gini && count(ismissing, gini_igac.area_ha) == n_missng_area_has

println("filter--", now())
gini_igac_perc = gini_igac[.!ismissing.(gini_igac.percentiles), :]
@assert all(combine(groupby(gini_igac_perc, :cod_muni), :cod_muni => length => :n_recs).n_recs .== 300)
gini_igac = gini_igac[ismissing.(gini_igac.percentiles), :]
@assert all(combine(groupby(gini_igac, :cod_muni), :cod_muni => length => :n_recs).n_recs .== 3)

println("select cols--", now())
n_cols_gini_igac_perc = ncol(gini_igac_perc)
n_col_igac = ncol(gini_igac)
vars_selct = setdiff(names(gini_igac), ["no_propietarios", "no_predios", "area_ha",
"area_m2", "disparidad_superior"])
select!(gini_igac_perc, vars_selct)
@assert ncol(gini_igac_perc) == n_cols_gini_igac_perc - 5
vars_selct = setdiff(names(gini_igac), ["percentiles"])
select!(gini_igac, vars_selct)
@assert ncol(gini_igac) == n_col_igac - 1

println("export--", now())
output_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/output/gini_igac.parquet"
output_2 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/output/gini_igac_perc.parquet"
write_parquet(gini_igac, output_1)
write_parquet(gini_igac_perc, output_2)
gini_igac = nothing
gini_igac_perc = nothing

println("done import_clean.jl--", now())