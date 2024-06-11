#
# Authors:     SCB, NAFM
# Maintainers: SCB, NAFM
# Copyright:   CEPAP
# Year: 2024
# =========================================

pacman::p_load(dplyr, logger, tidyr, arrow, purrr, assertr, stringr, digest,
               writexl)


log_info("DEFINE DIRECTORY")
if(dir.exists("/Users/sebas/OneDrive")){
  inpt_igac <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_agrpcr/output/igac_clean_names.parquet"
  
  otpt_igac <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_agrpcr/output/igac_pivot.parquet"
  
  otpt_cw <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_agrpcr/output/igac_cross_walk.xlsx"
} else {
  
  inpt_igac <- "/Users/nico//3_Resultados_Fragmentacion_Municipal.xlsx"
  
  otpt_igac <- "/Users/nico"
}


log_info("DEFINE FUNCTIONS")
verify_na <- function(variable_col){
  all(!is.na(variable_col))
}


hash_ids <- function(data_frame) {
  pmap(data_frame, list) %>%
    map_chr(digest, algo="sha1")
}

log_info("LOAD DATA")
igac <- read_parquet(inpt_igac)


log_info("VERIFY NA")
vec_cols_locatn <- c("departamento", "dane_dprtmnt", "municipio", "dane_mncp")

stopifnot(map_lgl(igac[vec_cols_locatn], verify_na))

n_row_igac <- nrow(igac)


log_info("PIVOT")
igac_fist_levl <- pivot_longer(igac,
                           cols = 6:length(colnames(igac)),
                           names_to = "carac_estruc_agra",
                           values_to = "valor")

stopifnot(length(colnames(igac_fist_levl)) == 7)

rm(igac)
gc()


log_info("RECORDID")
igac_fist_levl <- igac_fist_levl %>% 
  filter(!is.na(valor))
  
n_igac_fist_levl <- nrow(igac_fist_levl)

igac_fist_levl <- igac_fist_levl %>% 
  rename(recordid_old = recordid) %>% 
  mutate(recordid = hash_ids(.))

stopifnot(length(unique(igac_fist_levl$recordid)) == n_igac_fist_levl)

cross_walk <- igac_fist_levl %>% 
  select(recordid_old, recordid) %>% 
  distinct()

log_info("EXPORT")
write_xlsx(cross_walk, otpt_cw)

write_parquet(igac_fist_levl, otpt_igac)

rm(igac_fist_levl, list_estruc_agr)
gc()


log_info("DONE.")


