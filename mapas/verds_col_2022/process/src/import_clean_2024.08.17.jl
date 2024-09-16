#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, DataFrames, Random, Dates, Tables, TidierFiles, Shapefile, ArchGDAL

Random.seed!(19481210)

println("load data--", now())
input_1 = "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/verds_col_2022/process/input/Veredas_de_Colombia/Veredas_de_Colombia.shp"
output_1 = "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/verds_col_2022/process/output/shapefile_munis.arrow"

veredas = Shapefile.Table(input_1)

veredas_2 = ArchGDAL.read(input_1)

layer = ArchGDAL.getlayer(veredas_2, 0)

df = DataFrame(layer)

plot(df)

println("clean names--", now())
rename!(munis, lowercase.(names(munis)))

println("export--", now())
write_arrow(munis, output_1)

println("done import_clean.jl--", now())

Shapefile.Polygon(input_1)