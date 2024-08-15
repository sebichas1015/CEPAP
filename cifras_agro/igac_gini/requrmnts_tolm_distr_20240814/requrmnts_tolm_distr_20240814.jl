#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, Pipe, DataFrames, Random, Dates, Tables, TidierFiles, GeoMakie, ColorSchemes, CairoMakie, Shapefile, GeoInterface, GeoDataFrames, Plots, Makie

Random.seed!(19481210)

println("load data--", now())
input_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/munis_col_2021/process/output/shapefile_munis.arrow"
input_2 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/output/gini_igac.parquet"
output_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/output/gini_igac.parquet"

shape_munis = DataFrame(read_arrow(input_1))

gini_munis = DataFrame(read_parquet(input_2))

println("clean values--", now())
@pipe shape_munis |>
    filter!(:dpto_ccdgo => ==("73"), _) |>
    transform!(_, :mpio_cdpmp => ByRow(x -> parse(Int, x)) => :cod_muni) |>
    select!(_, [:cod_muni, :mpio_cnmbr, :geometry])

@pipe gini_munis |>
filter!(:area_de_estudio => ==("PREDIOS RURALES PRIVADOS"), _)

gini_shape = innerjoin(shape_munis, gini_munis, on = :cod_muni)