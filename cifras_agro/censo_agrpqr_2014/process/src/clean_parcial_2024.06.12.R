#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================

pacman::p_load(dplyr, tidyr, logger, assertr, arrow)


log_info("DEFINE DIRECTORY")
if(dir.exists("/Users/sebas/OneDrive")){
  input_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/output/censo_agro_import.parquet"
  
  output_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/output/censo_agro_clean.parquet"
} else {
  
  input_1 <- "/Users/nico//3_Resultados_Fragmentacion_Municipal.xlsx"
  
  output_1 <- "/Users/nico"
}


log_info("DEFINE FUNCTIONS")
verify_1to1 <- function(var_1, var_clean) {
  
  censo_agr_2014 %>% 
    select({{var_1}}, {{var_clean}}) %>% 
    distinct() %>% 
    group_by({{var_1}}, {{var_clean}}) %>% 
    summarise(list_var1 = n(),
              list_var_clean = n()) %>% 
    ungroup() %>% 
    verify(all(list_var1 == 1)) %>% 
    verify(all(list_var_clean == 1))
}

verify_names <- function(names_1, names_2, x, y) {
  stopifnot(length(setdiff(names_1, names_2)) == x)
  
  stopifnot(length(setdiff(names_2, names_1)) == y)
}


log_info("LOAD DATA")
vars_inpt <- c("recordid", "p_s12p150a", "s05_tenencia")

censo_agr_2014 <- read_parquet(input_1, col_select = all_of(vars_inpt))

cols_censo_agr_2014 <- colnames(censo_agr_2014)

n_censo_agr_2014 <- nrow(censo_agr_2014)


log_info("STANDARDIZE VALUES")
censo_agr_2014 <- censo_agr_2014 %>% 
  mutate(p_s12p150a_has_clean = p_s12p150a/10000) %>% 
  mutate(s05_tenencia_clean = case_when(
    s05_tenencia == 1 ~ "propia",
    s05_tenencia == 2 ~ "arriendo",
    s05_tenencia == 3 ~ "aparceria",
    s05_tenencia == 4 ~ "usufructo",
    s05_tenencia == 5 ~ "comodato",
    s05_tenencia == 6 ~ "ocupacion_de_hecho",
    s05_tenencia == 7 ~ "propiedad_colectiva",
    s05_tenencia == 8 ~ "adjudicatario_o_comunero",
    s05_tenencia == 9 ~ "otra_forma_de_tenencia",
    s05_tenencia == 11 ~ "mixta",
    s05_tenencia == 99 ~ "no_sabe", TRUE ~ NA))

verify_1to1(s05_tenencia, s05_tenencia_clean)

censo_agr_2014 <- censo_agr_2014 %>% 
  select(-p_s12p150a, -s05_tenencia) %>% 
  verify(nrow(.) == n_censo_agr_2014)

verify_names(cols_censo_agr_2014, colnames(censo_agr_2014), 2, 2)


log_info("EXPORT")
write_parquet(censo_agr_2014, output_1)

rm(censo_agr_2014)
gc()


log_info("DONE CLEAN.")
