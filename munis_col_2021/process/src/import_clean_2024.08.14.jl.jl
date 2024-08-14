#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, DataFrames, Random, Dates, Tables, TidierFiles, Shapefile

Random.seed!(19481210)

println("load data--", now())
input_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/munis_col_2021/process/input/SHP_MGN2021_COLOMBIA/MGN_2021_COLOMBIA/ADMINISTRATIVO/MGN_DPTO_POLITICO.shp"
output_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/munis_col_2021/process/output/shapefile_dpto.arrow"

deptos = DataFrame(Shapefile.Table(input_1))

println("clean names--", now())
rename!(deptos, lowercase.(names(deptos)))

println("export--", now())
write_arrow(deptos, output_1)

println("done import_clean.jl--", now())