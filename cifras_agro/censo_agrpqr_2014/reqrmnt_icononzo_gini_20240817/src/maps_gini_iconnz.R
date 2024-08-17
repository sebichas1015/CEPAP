#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================

pacman::p_load(readr, dplyr, tidyr, janitor, logger, assertr, purrr, arrow,
               digest, writexl, sf, ggplot2, forcats)

if(dir.exists("/Users/sebas/OneDrive")) {
  
  input_1 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/verds_col_2022/process/input/Veredas_de_Colombia/Veredas_de_Colombia.shp"
  
  input_2 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/cifras_agro/censo_agrpqr_2014/process/output/censo_agro_import.parquet"
  
  input_3 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/cifras_agro/censo_agrpqr_2014/process/output/censo_agro_clean.parquet"
  
  output_1 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/cifras_agro/censo_agrpqr_2014/reqrmnt_icononzo_gini_20240817/output/prop_stacked_barchart.png"
  
  output_2 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/cifras_agro/censo_agrpqr_2014/reqrmnt_icononzo_gini_20240817/output/prop_map_microf.png"
  
  output_3 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/cifras_agro/censo_agrpqr_2014/reqrmnt_icononzo_gini_20240817/output/prop_map_gran_pr.png"
  
} else {
  input_1 <- "/Users/ruta_nico"
  
  output_2 <- "/Users/ruta_nico"
}

log_info("load data")
vars_cns_imp <- c("recordid", "p_munic", "cod_vereda")

vars_cns_clen <- c("recordid", "p_s12p150a_has_clean")

cns_im <- read_parquet(input_2, col_select = all_of(vars_cns_imp))

cns_clan <- read_parquet(input_3, col_select = all_of(vars_cns_clen))

veredas <- read_sf(input_1) %>% 
  clean_names()

log_info("filter")
cns_im <- cns_im %>% 
  filter(p_munic == "73352")

veredas <- veredas %>% 
  filter(dptompio == "73352")

log_info("select vars")
veredas <- veredas %>% 
  select(codigo_ver, nombre_ver, geometry) %>% 
  assert(not_na, nombre_ver)

log_info("join")
n_row_cns_im <- nrow(cns_im)

cns_join <- cns_im %>% 
  left_join(cns_clan, by = "recordid") %>% 
  verify(nrow(.) == n_row_cns_im) %>% 
  filter(!is.na(p_s12p150a_has_clean))

n_row_cns_join <- nrow(cns_join)

cns_join <- cns_join %>% 
  left_join(veredas, by = c("cod_vereda" = "codigo_ver")) %>% 
  verify(nrow(.) == n_row_cns_join)

log_info("standardize vars")
cns_join <- cns_join %>% 
  mutate(nombre_ver = case_when(
    is.na(nombre_ver) ~ cod_vereda, TRUE ~ nombre_ver)) %>% 
  mutate(superficie_clas = case_when(
    p_s12p150a_has_clean < 3 ~ "microfundio",
    p_s12p150a_has_clean >= 3 & p_s12p150a_has_clean < 10 ~ "minifundio",
    p_s12p150a_has_clean >= 10 & p_s12p150a_has_clean < 20 ~ "pequena",
    p_s12p150a_has_clean >= 20 & p_s12p150a_has_clean < 200 ~ "mediana",
    p_s12p150a_has_clean >= 200 ~ "gran_propiedad", TRUE ~ NA))

log_info("process")
cns_sup_ver <- cns_join %>% 
  mutate(order_clas = case_when(
    superficie_clas == "microfundio" ~ 1,
    superficie_clas == "minifundio" ~ 2,
    superficie_clas == "pequena" ~ 3,
    superficie_clas == "mediana" ~ 4,
    superficie_clas == "gran_propiedad" ~ 5, TRUE ~ NA)) %>% 
  group_by(cod_vereda) %>% 
  mutate(total_has = sum(p_s12p150a_has_clean)) %>% 
  group_by(cod_vereda, superficie_clas) %>% 
  mutate(total_clas_sup = sum(p_s12p150a_has_clean)) %>% 
  ungroup() %>% 
  mutate(prop_clas_sup = (total_clas_sup/total_has)) %>% 
  arrange(order_clas, desc(prop_clas_sup)) %>% 
  select(-recordid, -p_s12p150a_has_clean, -p_munic) %>% 
  distinct()
  
rm(cns_clan, cns_im, cns_join)
gc()

log_info("data to grahps")  
graph_distr <- cns_sup_ver %>% 
  ggplot(aes(fill = superficie_clas, y = prop_clas_sup, x = nombre_ver)) +
  geom_bar(position="stack", stat="identity") +
  coord_flip() +
  scale_fill_manual(values = c("#f6a6b2", "#ffecb8", "#90d2d8", "#f7c297",
                               "#94dec7", "#b7ded2")) +
  theme_minimal()

map_micro <- cns_sup_ver %>% 
  filter(superficie_clas == "microfundio") %>% 
  rename(prop_microfundio = prop_clas_sup) %>% 
  ggplot() +
  geom_sf(aes(fill = prop_microfundio, geometry = geometry)) +
  scale_fill_gradient(low = "#ffacb8", high =  "#a60a21") +
  theme_minimal()

map_gran_propiedad <- cns_sup_ver %>% 
  filter(superficie_clas == "gran_propiedad") %>% 
  rename(prop_gran_propiedad = prop_clas_sup) %>% 
  ggplot() +
  geom_sf(data = veredas, alpha = 0) +
  geom_sf(aes(fill = prop_gran_propiedad, geometry = geometry)) +
  scale_fill_gradient(low = "#ffacb8", high =  "#a60a21") +
  theme_minimal()

log_info("export")
ggsave(output_1, plot = graph_distr, width = 8, height = 6, dpi = 300)

ggsave(output_2, plot = map_micro, width = 8, height = 6, dpi = 200)

ggsave(output_3, plot = map_gran_propiedad, width = 8, height = 6, dpi = 200)

log_info("done code_graphs_ver_icnnz.R")