#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================

pacman::p_load(readr, dplyr, tidyr, janitor, logger, assertr, purrr, arrow,
               digest, data.table)

log_info("DEFINE DIRECTORY")
if(dir.exists("/Users/sebas/OneDrive")){
  input_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/data_orgn/S01_15(Unidad_productora).csv"
  
  output_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/data_orgn/censo_agro_import.parquet"
} else {
  
  input_1 <- "/Users/nico//3_Resultados_Fragmentacion_Municipal.xlsx"
  
  output_1 <- "/Users/nico"
}


log_info("DEFINE FUNCTIONS")
hash_ids <- function(data_frame) {
  pmap(data_frame[, c("n_row")], list) %>%
    map_chr(digest, algo = "sha1")
}

verify_names <- function(names_1, names_2, x) {
  stopifnot(length(setdiff(names_1, names_2)) == 0)
  
  stopifnot(length(setdiff(names_2, names_1)) == x)
}


log_info("LOAD DATA")
censo_agr_2014 <- read_csv(input_1) %>% 
  clean_names() %>% 
  as_tibble()

n_censo_agr_2014 <- nrow(censo_agr_2014)

cols_censo_agr_2014 <- colnames(censo_agr_2014)

gc()


log_info("CREATE RECORDID")
censo_agr_2014 %>% 
  distinct() %>% 
  verify(nrow(.) == n_censo_agr_2014)

censo_agr_2014 <- censo_agr_2014 %>% 
  mutate(n_row = row_number()) %>% 
  mutate(recordid = hash_ids(.)) %>% 
  select(-n_row)

stopifnot(length(unique(censo_agr_2014$recordid)) == n_censo_agr_2014)

verify_names(cols_censo_agr_2014, colnames(censo_agr_2014), 1)


log_info("EXPORT")
write_parquet(censo_agr_2014, output_1)

rm(censo_agr_2014)
gc()


log_info("DONE.")
