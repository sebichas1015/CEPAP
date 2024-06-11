#
# Authors:     SCB, NAFM
# Maintainers: SCB, NAFM
# Copyright:   CEPAP
# Year: 2024
# =========================================

pacman::p_load(janitor, dplyr, logger, openxlsx, stringr, tidyr, purrr, arrow,
               digest)


log_info("DEFINE DIRECTORY")
if(dir.exists("/Users/sebas/OneDrive")){
  inpt_igac <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_agrpcr/input/3_Resultados_Fragmentacion_Municipal.xlsx"
  
  otpt_igac <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_agrpcr/output/igac_clean_names.parquet"
} else {
  
  inpt_igac <- "/Users/nico//3_Resultados_Fragmentacion_Municipal.xlsx"
  
  otpt_igac <- "/Users/nico"
}


log_info("DEFINE FUNCTIONS")
hash_ids <- function(data_frame) {
  pmap(data_frame, list) %>%
    map_chr(digest, algo = "sha1")
}


log_info("LOAD DATA")
igac <- read.xlsx(inpt_igac, startRow = 4) %>% 
  clean_names()


log_info("PROCESS NAMES")
names_clean_1 <- c("departamento", "dane_dprtmnt", "municipio", "dane_mncp",
                 "pri_estrctr_cntdd_prds_ltfd_intgr", "pri_estrctr_cntdd_prds_mdn_intgr",
                 "pri_estrctr_cntdd_prds_pqnia_intgr", "pri_estrctr_cntdd_prds_mnfnd_intgr",
                 "pri_estrctr_cntdd_prds_mcfnd_intgr", "delete_10")

names_clean_2 <- str_replace_all(names_clean_1, "intgr", "prprcn")

names_clean_join_1 <- union(names_clean_1, names_clean_2)

names_clean_join_1 <- c(names_clean_join_1, "delete_16")

names_clean_3 <- str_replace_all(names_clean_join_1, "cntdd", "area")

names_clean_3[10] <- "delete_22"

names_clean_3[16] <- "delete_28"

names_clean_join_1 <- union(names_clean_join_1, names_clean_3)


names_clean_4 <- str_replace_all(names_clean_join_1, "pri", "frontera_no_agro")

names_clean_4[10] <- "delete_34"

names_clean_4[16] <- "delete_40"

names_clean_4[22] <- "delete_46"

names_clean_4[28] <- "delete_52"

names_clean_join_2 <- union(names_clean_join_1, names_clean_4)


names_clean_5 <- str_replace_all(names_clean_join_1, "pri", "frnt")

names_clean_5[10] <- "delete_58"

names_clean_5[16] <- "delete_64"

names_clean_5[22] <- "delete_70"

names_clean_join_3 <- union(names_clean_join_2, names_clean_5)

names_clean_join_3 <- c(names_clean_join_3, "delete_76")


log_info("CHANGE NAMES")
colnames(igac) <- names_clean_join_3

igac <- igac %>% 
  select(-starts_with("delete")) %>% 
  mutate(recordid = hash_ids(.)) %>% 
  relocate(recordid)

n_igac <- nrow(igac)

stopifnot(length(unique(igac$recordid)) == n_igac)

log_info("EXPORT")
write_parquet(igac, otpt_igac)

rm(igac)
gc()

log_info("DONE.")
