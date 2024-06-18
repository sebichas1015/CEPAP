#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================

pacman::p_load(readr, dplyr, tidyr, janitor, logger, assertr, purrr, arrow,
               digest, writexl)

if(dir.exists("/Users/sebas/OneDrive")) {
  
  input_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/process/output/censo_agro_import.parquet"
  
  input_2 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/process/output/censo_agro_clean.parquet"
  
  output_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/cifras_agro/censo_agrpqr_2014/reqrmnt_icononzo_castillo_2024.06.12/output/resultados_incononzo_castillo.xlsx"
} else {
  input_1 <- "/Users/ruta_nico"
  
  output_2 <- "/Users/ruta_nico"
}


log_info("DEFINE FUNCTIONS")
verify_names <- function(names_1, names_2, x, y) {
  stopifnot(length(setdiff(names_1, names_2)) == x)
  
  stopifnot(length(setdiff(names_2, names_1)) == y)
}

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

log_info("LOAD DATA")
vars_inpt_imprt <- c("recordid", "p_s6p61_sp1", "p_s6p61_sp2", "p_s6p61_sp3",
                     "p_s6p61_sp4", "p_s6p61_sp5", "p_s6p61_sp6", "p_s6p61_sp7",
                     "p_s6p61_sp8", "p_s6p61_sp9", "p_s6p61_sp10", "p_s6p61_sp11",
                     "p_s11p134_sp1", "p_s11p134_sp2", "p_s11p134_sp3",
                     "p_s11p134_sp4", "p_s11p134_sp5", "p_s11p134_sp6",
                     "p_s11p134_sp7", "p_s11p136a", "p_munic", "pred_etnica")

censo_agr_2014_imprt <- read_parquet(input_1, col_select = all_of(vars_inpt_imprt))

censo_agr_2014_clean <- read_parquet(input_2)

cols_censo_agr_2014_clean <- colnames(censo_agr_2014_clean)

stopifnot(nrow(censo_agr_2014_imprt) == nrow(censo_agr_2014_clean))


log_info("JOIN DATA")
n_censo_agr_2014_clean <- nrow(censo_agr_2014_clean)

censo_agr_2014 <- censo_agr_2014_clean %>% 
  inner_join(censo_agr_2014_imprt, by = "recordid") %>% 
  verify(nrow(.) == n_censo_agr_2014_clean)

names_total <- c(cols_censo_agr_2014_clean, vars_inpt_imprt)

verify_names(names_total, colnames(censo_agr_2014), 0, 0)

rm(censo_agr_2014_clean, censo_agr_2014_imprt)
gc()


log_info("FILTER")
censo_agr_2014 <- censo_agr_2014 %>% 
  filter(p_munic %in% c("73352", "50251"))


log_info("CLEAN")
censo_agr_2014 <- censo_agr_2014 %>% 
  mutate(municipio = case_when(
    p_munic == "73352" ~ "icononzo",
    p_munic == "50251" ~ "the_castle"))


log_info("PROCESS")
result_1 <- censo_agr_2014 %>% 
  filter(pred_etnica == 7) %>% 
  mutate(superficie_clas = case_when(
    p_s12p150a_has_clean < 3 ~ "microfundio",
    p_s12p150a_has_clean >= 3 & p_s12p150a_has_clean < 10 ~ "minifundio",
    p_s12p150a_has_clean >= 10 & p_s12p150a_has_clean < 20 ~ "pequena",
    p_s12p150a_has_clean >= 20 & p_s12p150a_has_clean < 200 ~ "mediana",
    p_s12p150a_has_clean >= 200 ~ "gran_propiedad", TRUE ~ NA)) %>% 
  group_by(superficie_clas, municipio) %>%
  summarise(total_cantidad_upa = n(),
            total_area_has = sum(p_s12p150a_has_clean, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(total_area_has = round(total_area_has, 1)) %>% 
  group_by(municipio) %>% 
  mutate(prop_area = sum(total_area_has, na.rm = TRUE)) %>% 
  mutate(prop_area = (total_area_has*100)/prop_area) %>%
  mutate(prop_area = round(prop_area, digits = 1)) %>% 
  mutate(prop_area = paste0(prop_area, "%")) %>% 
  filter(!is.na(superficie_clas)) %>% 
  arrange(municipio)
  


result_2 <- censo_agr_2014 %>% 
  group_by(s05_tenencia_clean, municipio) %>% 
  summarise(total_cantidad_upa = n(),
            total_area_has = sum(p_s12p150a_has_clean, na.rm = TRUE)) %>% 
  ungroup() %>% 
  group_by(municipio) %>% 
  mutate(prop_area = sum(total_area_has, na.rm = TRUE)) %>% 
  mutate(prop_area = (total_area_has*100)/prop_area) %>%
  mutate(prop_area = round(prop_area, digits = 1)) %>% 
  mutate(prop_area = paste0(prop_area, "%")) %>% 
  mutate(total_area_has = round(total_area_has, 1)) %>% 
  filter(!is.na(s05_tenencia_clean)) %>% 
  arrange(municipio)


result_3 <- censo_agr_2014 %>% 
  select(p_s12p150a_has_clean, municipio, p_s6p61_sp1, p_s6p61_sp2, p_s6p61_sp3,
         p_s6p61_sp4, p_s6p61_sp5, p_s6p61_sp6, p_s6p61_sp7, p_s6p61_sp8,
         p_s6p61_sp9, p_s6p61_sp10, p_s6p61_sp11, recordid) %>% 
  pivot_longer(cols = c(p_s6p61_sp1, p_s6p61_sp2, p_s6p61_sp3, p_s6p61_sp4,
                        p_s6p61_sp5, p_s6p61_sp6, p_s6p61_sp7, p_s6p61_sp8,
                        p_s6p61_sp9, p_s6p61_sp10, p_s6p61_sp11),
               names_to = "destino_final_produccion",
               values_to = "valor") %>% 
  filter(!is.na(valor)) %>% 
  filter(valor == 1) %>% 
  mutate(destino_final_produccion = case_when(
    destino_final_produccion == "p_s6p61_sp1" ~ "autoconsumo",
    destino_final_produccion == "p_s6p61_sp2" ~ "intercambio_o_trueque",
    destino_final_produccion == "p_s6p61_sp3" ~ "venta_del_producto_en_lote",
    destino_final_produccion == "p_s6p61_sp4" ~ "venta_a_cooperativa",
    destino_final_produccion == "p_s6p61_sp5" ~ "venta_a_central_de_abastos",
    destino_final_produccion == "p_s6p61_sp6" ~ "venta_directa_en_plaza_de_mercado",
    destino_final_produccion == "p_s6p61_sp7" ~ "venta_a_comercializador",
    destino_final_produccion == "p_s6p61_sp8" ~ "venta_a_tienda_supermercado_grandes_superficies",
    destino_final_produccion == "p_s6p61_sp9" ~ "venta_a_mercado_internacional",
    destino_final_produccion == "p_s6p61_sp10" ~ "para_la_industria",
    destino_final_produccion == "p_s6p61_sp11" ~ "otros_destinos")) %>% 
  group_by(municipio, destino_final_produccion) %>% 
  summarise(total_cantidad_upa = n(),
            total_area_has = sum(p_s12p150a_has_clean, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(total_area_has = round(total_area_has, 1)) %>% 
  group_by(municipio) %>% 
  mutate(prop_area = sum(total_area_has, na.rm = TRUE)) %>% 
  mutate(prop_area = (total_area_has*100)/prop_area) %>%
  mutate(prop_area = round(prop_area, digits = 1)) %>% 
  mutate(prop_area = paste0(prop_area, "%")) %>% 
  arrange(municipio)


result_4 <- censo_agr_2014 %>% 
  select(recordid, municipio, p_s11p134_sp1, p_s11p134_sp2,
         p_s11p134_sp3, p_s11p134_sp4, p_s11p134_sp5, p_s11p134_sp6,
         p_s11p134_sp7) %>% 
  pivot_longer(cols = c(p_s11p134_sp1, p_s11p134_sp2, p_s11p134_sp3,
                        p_s11p134_sp4, p_s11p134_sp5, p_s11p134_sp6,
                        p_s11p134_sp7),
               names_to = "pertenencia_asociacion",
               values_to = "valor") %>% 
  filter(!is.na(valor)) %>% 
  filter(valor == 1) %>% 
  mutate(pertenencia_asociacion = case_when(
    pertenencia_asociacion == "p_s11p134_sp1" ~ "cooperativas",
    pertenencia_asociacion == "p_s11p134_sp2" ~ "gremios",
    pertenencia_asociacion == "p_s11p134_sp3" ~ "asociacion_de_productores",
    pertenencia_asociacion == "p_s11p134_sp4" ~ "centros_de_investigacion",
    pertenencia_asociacion == "p_s11p134_sp5" ~ "organizaciones_comunitarias",
    pertenencia_asociacion == "p_s11p134_sp6" ~ "no_pertenece_a_ninguna_asociacion",
    pertenencia_asociacion == "p_s11p134_sp7" ~ "no_sabe_no_responde")) %>% 
  group_by(municipio, pertenencia_asociacion) %>% 
  summarise(total_cantidad_upa = n()) %>% 
  ungroup() %>% 
  group_by(municipio) %>% 
  mutate(prop_upas = sum(total_cantidad_upa, na.rm = TRUE)) %>% 
  mutate(prop_upas = (total_cantidad_upa*100)/prop_upas) %>%
  mutate(prop_upas = round(prop_upas, digits = 1)) %>% 
  mutate(prop_upas = paste0(prop_upas, "%")) %>% 
  arrange(municipio)


result_5 <- censo_agr_2014 %>% 
  filter(!is.na(p_s11p136a)) %>% 
  rename(solicitud_credito = p_s11p136a) %>% 
  mutate(solicitud_credito = case_when(
    solicitud_credito == 0 ~ "no_solicito_credito",
    solicitud_credito == 1 ~ "solicitud_credito_aprobada",
    solicitud_credito == 2 ~ "solicitud_credito_no_aprobada")) %>% 
  group_by(solicitud_credito, municipio) %>% 
  summarise(cantidad = n()) %>% 
  ungroup() %>% 
  arrange(municipio)

rm(censo_agr_2014)
gc()


log_info("EXPORT")
results_icononzo_castillo <- list(estructura_propiedad = result_1,
                                  formas_tenencia = result_2,
                                  destino_poduccion = result_3,
                                  pertenencia_asociaciones = result_4,
                                  acceso_credito = result_5)

write_xlsx(results_icononzo_castillo, output_1)
  

log_info("DONE RESULTS.")



