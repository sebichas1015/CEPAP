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
                    default = ("/mnt/c/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_violnc/cnmh_victimas/import/output/"))
args <- parser$parse_args()

log_info("create functions")
read_tables <- function(paths_tables) {

  source_table <- str_remove(paths_tables, args$input)

  source_table <- str_remove_all(source_table, "/|.xlsx")

  df <- read.xlsx(paths_tables) %>%
    mutate(recordid = hash_ids(.)) %>%
    clean_names() %>%
    mutate(source = source_table)

  return (df)
}

hash_ids <- function(data_frame) {
  pmap(data_frame, list) %>%
    map_chr(digest, algo = "sha1")
}

write_export <- function(df) {
  path_exprt <- unique(df$source)

  stopifnot(length(paths_export) == 1)

  path_exprt <- paste0(args$output_result1,
                         path_exprt, ".parquet")

  return(path_exprt)
}

log_info("load data")
paths <- list.files(args$input, full.names = TRUE)

tables_cnmh <- map(paths, ~read_tables(.x))

log_info("verify colnames")
colnames_tables <- map(tables_cnmh, colnames)

# names are distinct

log_info("export")
walk(tables_cnmh, ~ write_parquet(.x, paths_export(.x))

