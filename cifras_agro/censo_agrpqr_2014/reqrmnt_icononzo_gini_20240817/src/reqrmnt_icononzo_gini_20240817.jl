#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, DataFrames, Random, Dates, Tables, TidierFiles, Gadfly, Compose, ColorSchemes, Cairo

Random.seed!(19481210)

println("load data--", now())
input_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/output/gini_igac.parquet"
output_1 = "C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/requrmnts_munis_distr_2024.08.10/prueba.png"

gini_igac = read_parquet(input_1)

minim_value = gini_igac[argmin(gini_igac.gini), :]

minmn_vals_dpto = combine(groupby(gini_igac, [:area_de_estudio, :departamento]), :gini => minimum => :min_gini)

gini_may_0 = filter(row -> row.gini != 0, gini_igac)

minmn_vals_dpto_may0 = combine(groupby(gini_may_0, [:area_de_estudio, :departamento]), :gini => minimum => :min_gini)

min_gini_df = combine(groupby(gini_may_0, [:area_de_estudio, :departamento])) do subdf
    idx_min = argmin(subdf.gini)
    return subdf[idx_min, :]
end

min_gini_df_2 = filter(row -> row.area_de_estudio == "PREDIOS RURALES PRIVADOS", min_gini_df)

min_gini_df_3 = min_gini_df_2[[1, 2, 3, 4, 5], :]

graph_1 = plot(
    min_gini_df_3,
    x = :municipio,
    y = :gini,
    alpha = [0.5],
    Geom.bar,
    Guide.xlabel("Municipio"),
    Guide.ylabel("Gini"),
    Guide.title("Distribución del índice Gini por Municipio"),
    Theme(
        background_color = "white",
        default_color = "black",
        bar_spacing = 1mm
    )
)

draw(PNG(output_1, 6inch, 4inch, dpi = 300), graph_1)
