#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, DataFrames, Tables, CSV, StatsBase, Dates, Arrow, Random, StringEncodings

Random.seed!(19481210)

input_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/input/GINI_MUNICIPAL_PERCENTILES.csv"

gini_igac = DataFrame(CSV.File(open(input_1, enc"ISO-8859-1")))



