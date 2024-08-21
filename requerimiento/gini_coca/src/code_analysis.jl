#
# Authors:     Sebas
# Maintainers: Sebas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

using Pkg, DataFrames, Random, Dates, Tables, TidierFiles, Shapefile, ArgParse, Pipe, Cleaner

Random.seed!(19481210)

cd("C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/")

println("define args--", now())
s = ArgParseSettings()
@add_arg_table s begin
    "--coca_2022"
        arg_type = String
        default = "cifras_agro/coca_munis_2022/process/output/coca_2022_clean.parquet"
    "--gini_muni" 
        arg_type = String
        default = "cifras_agro/igac_gini/process/output/gini_igac.parquet"
    "--munis_area"
        default = "munis_col_2021/process/input/SHP_MGN2021_COLOMBIA/MGN_2021_COLOMBIA/ADMINISTRATIVO/MGN_MPIO_POLITICO.shp"
end

parsed_args = parse_args(s)

println("load data--", now())
table_shape_munis = parsed_args["munis_area"] |>
    Shapefile.Table |>
    DataFrame |>
    rename |>
    df -> DataFrame(polish_names(rename(df, lowercase.((names(df))))))

coca_2022 = read_parquet(parsed_args["coca_2022"])

gini_muni = parsed_args["gini_muni"] |>
    read_parquet |>
    df -> DataFrame(polish_names(df))


