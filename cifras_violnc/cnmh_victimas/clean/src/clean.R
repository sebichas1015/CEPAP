#
# Authors: SCB
# Maintainers: SCB
# Copyright: CEPAP
# Year: 2024
# =========================================

pacman::p_load(janitor, dplyr, logger, openxlsx, stringr, tidyr, purrr, arrow,
               digest, argparse)

log_info("define args")
parser <- ArgumentParser()
parser$add_argument("--input",
                    default = ("/mnt/c/Users/sebas/OneDrive/Documents/CEPAP/team_data/data_orginal/cnmh/input/"))
parser$add_argument("--output_result1",
                    default = ("/mnt/c/Users/sebas/OneDrive/Documents/r_pruebas/audit_long/output/result_1.parquet"))
args <- parser$parse_args()

log_info("create functions")
read_tables <- function(paths_tables) {

  df <- read.xlsx(paths_tables) %>%
    clean_names() %>%
    mutate(source_table = paths_tables)

  return (df)
}

log_info("load data")
paths <- list.files(args$input, full.names = TRUE)

tables_cnmh <- map(paths, ~read_tables(.x))

log_info("verify colnames")
colnames_tables <- map(tables_cnmh, colnames)

# names are distinct

log_info("standardize names")
tables_cnmh[[9]] <- tables_cnmh[[9]] %>%
  pivot_longer(
               cols = c("caletera", "campanera", "cocinera",
               "comandante", "combatiente", "contabilidad",
               "entrenamiento", "escolta", "guardia",
               "informante", "patrullera", "raspachin",
               "servicios_de_salud", "trabajo_organizativo",
               "transporte_de_armas",
               "sin_informacion_de_oficios_realizados"),
               names_to = "ocupacion_2",
               values_to = "value"
               ) %>%
  filter(value == 1)


prueba_2 <- bind_rows(tables_cnmh)

