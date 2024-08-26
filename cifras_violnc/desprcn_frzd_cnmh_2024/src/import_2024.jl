#
# Authors:     Sebas
# Maintainers: Sebas
# Year: 2024
# =========================================
# cifras_agro/desprcn_frzd_cnmh_2024/src/import_2024.jl

using Pkg, DataFrames, Random, Dates, Tables, TidierFiles, ArgParse, Pipe, Cleaner, Transliterate

Random.seed!(19481210)

cd("C:/Users/sebas/OneDrive/Documents/CEPAP/team_data/")

println("define args--", now())
s = ArgParseSettings()
@add_arg_table s begin
    "--input_cnmh"
        default = "cifras_violnc/desprcn_frzd_cnmh_2024/input/VictimasDF_202403.xlsx"
    "--output_cnmh"
        arg_type = String
        default = "cifras_violnc/desprcn_frzd_cnmh_2024/output/import_desprcn_2024.parquet"
end

parsed_args = parse_args(s)

println("load functions--", now())
function coerce_string(item)
    return ismissing(item) ? missing : string(item)
end

println("load data--", now())
desprcn_cnmh = read_xlsx(parsed_args["input_cnmh"])

println("clean names--", now())
desprcn_cnmh = rename(desprcn_cnmh, Symbol.(transliterate.(string.(lowercase.(names(desprcn_cnmh)))))) |>
    polish_names |>
    DataFrame

println("clean data--", now())
transform!(desprcn_cnmh, AsTable(:) => ByRow(row -> hash(string(row...))) => :record_id)

transform!(desprcn_cnmh, names(desprcn_cnmh) .=> ByRow(coerce_string) .=> names(desprcn_cnmh))

println("export--", now())
write_parquet(desprcn_cnmh, parsed_args["output_cnmh"])

println("done import_2024.jl--", now())