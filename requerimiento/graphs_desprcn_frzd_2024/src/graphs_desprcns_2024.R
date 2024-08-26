#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================
# requerimiento/graphs_desprcn_frzd_2024/src/graphs_desprcns_2024.R

pacman::p_load(readr, dplyr, janitor, logger, assertr, purrr, arrow, sf,
               ggplot2, stringr)

setwd("/Users/sebas/OneDrive/Documents/CEPAP/team_data/")

input_1 <- "cifras_violnc/desprcn_frzd_cnmh_2024/output/import_desprcn_2024.parquet"

input_2 <- "munis_col_2023/input/MGN2023_MPIO_POLITICO/MGN_ADM_MPIO_GRAFICO.shp"

output_1 <- "requerimiento/graphs_desprcn_frzd_2024/output/time_serie_anio.pdf"

output_2 <- "requerimiento/graphs_desprcn_frzd_2024/output/barr_ethnic.pdf"

output_3 <- "requerimiento/graphs_desprcn_frzd_2024/output/map_munis.pdf"

output_4 <- "requerimiento/graphs_desprcn_frzd_2024/output/tor_sex.pdf"

log_info("define functions")
coerce_integer <- function(vec_x) {
  n_na_1 <- sum(is.na(vec_x))
  
  vec_x <- as.integer(vec_x)
  
  n_na_2 <- sum(is.na(vec_x))
  
  stopifnot(n_na_1 == n_na_2)
  
  return(vec_x)
}

log_info("load data")
desprcns_cnmh <- read_parquet(input_1)

munis_shap <- read_sf(input_2) %>% 
  clean_names()

log_info("filter")
desprcns_cnmh <- desprcns_cnmh %>% 
  mutate(ano = coerce_integer(ano)) %>% 
  filter(ano > 1963)

log_info("process")
time_serie <- desprcns_cnmh %>% 
  group_by(ano) %>% 
  summarise(n_victs = n_distinct(id_persona)) %>% 
  ungroup()

barr_plot <- desprcns_cnmh %>% 
  filter(!(is.na(etnia))) %>% 
  group_by(etnia) %>% 
  summarise(n_victs = n_distinct(id_persona)) %>% 
  ungroup()

munis_map <- desprcns_cnmh %>% 
  group_by(codigo_dane_de_municipio) %>% 
  summarise(n_victs = n_distinct(id_persona)) %>% 
  ungroup()

n_munis_map <- nrow(munis_map)

munis_map <- munis_map %>% 
  left_join(munis_shap, by = c("codigo_dane_de_municipio" = "mpio_cdpmp")) %>% 
  verify(nrow(.) == n_munis_map)

sex_tor <- desprcns_cnmh %>% 
  group_by(sexo) %>% 
  summarise(n_victs = n_distinct(id_persona)) %>% 
  ungroup() %>% 
  filter(!str_detect(sexo, "INFOR")) %>% 
  mutate(prop_sex = sum(n_victs)) %>% 
  mutate(prop_sex = n_victs/prop_sex)

log_info("graphs")
graph_time_serie <- time_serie %>% 
  mutate(ano = as.integer(ano)) %>% 
  ggplot(aes(x = ano, y = n_victs)) +
  geom_line(color = "#f8c952", size = 2) +
  scale_x_continuous(breaks = seq(min(time_serie$ano), max(time_serie$ano), by = 5)) +
  theme_minimal()

graph_barr <- barr_plot %>% 
  mutate(etnia = recode(etnia,
                        "NEGRO(A), MULATO(A), AFRODESCENDIENTE, AFROCOLOMBIANO(A)" =
                          "NEGRO(A), MULATO(A),\n AFRODESCENDIENTE,\n AFROCOLOMBIANO(A)",
                        "RAIZAL DEL ARCHIPIÉLAGO DE SAN ANDRÉS, PROVIDENCIA Y SANTA CATALINA" =
                          "RAIZAL DEL ARCHIPIÉLAGO\n DE SAN ANDRÉS, PROVIDENCIA\n Y SANTA CATALINA")) %>% 
  ggplot(aes(x = etnia, y = n_victs)) +
  geom_bar(stat = "identity", fill = "#f8c952") +
  coord_flip() +
  theme_minimal()

graph_map <- ggplot() +
  geom_sf(data = munis_shap, alpha = 0) +
  geom_sf(data = munis_map, aes(fill = n_victs, geometry = geometry)) +
  scale_fill_gradient(low = "#f8c952", high = "#cc4778") +
  theme_minimal()

graph_tor <- ggplot(sex_tor, aes(x="", y= prop_sex, fill=sexo)) +
  geom_bar(stat="identity", width=1, color="white", size = 1) +
  coord_polar("y", start=0) +
  theme_void() + 
  theme(legend.position="none") +
  #geom_text(aes(y = prop_sex, label = sexo), color = "white", size=4) +
  scale_fill_manual(values = c("#f8c952", "#cc4778"))

log_info("export")
ggsave(output_1, plot = graph_time_serie, width = 8, height = 6, dpi = 300)

ggsave(output_2, plot = graph_barr, width = 8, height = 6, dpi = 300)

ggsave(output_3, plot = graph_map, width = 8, height = 6, dpi = 80)

ggsave(output_4, plot = graph_tor, width = 8, height = 6, dpi = 300)

log_info("done graphs_desprcns_2024.R")