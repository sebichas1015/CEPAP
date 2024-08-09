#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# CEPAP/team_data/cifras_agro/igac_gini/input/GINI_MUNICIPAL_PERCENTILES.csv

pacman::p_load(argparse, here, dplyr, arrow, assertr, logger, readr, janitor,
               stringi, stringr)

set.seed(19481210)

if(dir.exists("/Users/sebas/OneDrive")) {
  
  input_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/igac_gini/process/input/GINI_MUNICIPAL_PERCENTILES.csv"
  
  output_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/reqrmnt_icononzo_castillo_2024.06.12/output/resultados_incononzo_castillo.xlsx"
} else {
  input_1 <- "/Users/ruta_nico"
}

log_info("load data")
gini_igac <- read_delim(input_1, delim = ";", locale = locale(encoding = "ISO-8859-1"))

log_info("clean")
gini_igac <- gini_igac %>% 
  clean_names()

n_na_gini <- sum(is.na(gini_igac$gini))

gini_igac <- gini_igac %>% 
  mutate_if(is.character, ~stri_trans_general(., "latin-ascii")) %>% 
  mutate(gini = str_replace_all(gini, ",", ".")) %>% 
  mutate(gini = as.numeric(gini)) %>% 
  verify(sum(is.na(gini)) == n_na_gini)

log_info("filter")
gini_igac_perc <- gini_igac %>% 
  filter(!(is.na(percentiles)))

gini_igac_perc %>% 
  group_by(cod_muni) %>% 
  summarise(n_recs = n()) %>% 
  ungroup() %>% 
  verify(all(n_recs == 300))

gini_igac <- gini_igac %>% 
  filter(is.na(percentiles))

gini_igac %>% 
  group_by(cod_muni) %>% 
  summarise(n_recs = n()) %>% 
  ungroup() %>% 
  verify(all(n_recs == 3))

log_info("select cols")
n_cols_gini_igac <- ncol(gini_igac)

gini_igac_perc <- gini_igac_perc %>% 
  select(-no_propietarios, -no_predios, -area_ha, -area_m2, -disparidad_superior) %>% 
  verify(ncol(.) == n_cols_gini_igac - 5)



