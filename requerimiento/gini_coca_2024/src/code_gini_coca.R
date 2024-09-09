#
# Authors:     SCB
# Maintainers: SCB
# Copyright: 2024
# =========================================
# CO-JXXXXXXXXXX

pacman::p_load(argparse, here, dplyr, logger, arrow, assertr, openxlsx, janitor,
               tidyr, stringr, sf, rmapshaper, ggplot2, magick, cowplot, forcats)

setwd("/Users/sebas/OneDrive/Documents/CEPAP/team_data/")

parser <- ArgumentParser()
parser$add_argument("--coca_2022",
                    default = "cifras_agro/coca_munis_2022/process/output/coca_2022_clean.parquet")
parser$add_argument("--gini_muni",
                    default = "cifras_agro/igac_gini/process/output/gini_igac.parquet")
parser$add_argument("--logo_cepap",
                    default = "cepap_general/input/logo_rgb_transparente.png")
parser$add_argument("--munis_area",
                    default = "munis_col_2021/process/input/SHP_MGN2021_COLOMBIA/MGN_2021_COLOMBIA/ADMINISTRATIVO/MGN_MPIO_POLITICO.shp")
parser$add_argument("--graph_map_gini",
                    default = "requerimiento/gini_coca_2024/output/graph_map_gini.pdf")
parser$add_argument("--graph_map_coca",
                    default = "requerimiento/gini_coca_2024/output/graph_map_coca.pdf")
parser$add_argument("--graph_map_coca_prop",
                    default = "requerimiento/gini_coca_2024/output/graph_map_coca_prop.pdf")
parser$add_argument("--graph_barr_top_gini",
                    default = "requerimiento/gini_coca_2024/output/graph_barr_top_gini.pdf")
parser$add_argument("--graph_barr_top_coca",
                    default = "requerimiento/gini_coca_2024/output/graph_barr_top_coca.pdf")
parser$add_argument("--graph_barr_top_coca_prop",
                    default = "requerimiento/gini_coca_2024/output/graph_barr_top_coca_prop.pdf")
parser$add_argument("--graph_scatter_gini_coca",
                    default = "requerimiento/gini_coca_2024/output/graph_scatter_gini_coca.pdf")
parser$add_argument("--graph_scatter_gini_coca_prop",
                    default = "requerimiento/gini_coca_2024/output/graph_scatter_gini_coca_prop.pdf")
args <- parser$parse_args()

log_info("load functions")
coerce_number <- function(x) {
  n_na <- sum(is.na(x))
  
  x <- as.numeric(x)
  
  n_na_new <- sum(is.na(x))
  
  stopifnot(n_na == n_na_new)
  
  return(x)
}

plot_map <- function(shape_backgrnd, shape_score, var_score) {
  grap_map <- ggplot() +
    geom_sf(data = shape_backgrnd, alpha = 0) +
    geom_sf(data = shape_score, aes(fill = {{var_score}}, geometry = geometry)) +
    scale_fill_gradient(low = "#f8c952", high = "#cc4778") +
    theme_minimal()
  
  grap_map <- ggdraw(grap_map) +
    draw_image(logo, x = 0.19, y = 0.01, width = 0.3, height = 0.3)
  
  return(grap_map)
}

graph_barr <- function(df, var_score) {
  graph_barr <- df %>% 
    filter(!is.na(mpio_cnmbr)) %>% 
    assert(not_na, mpio_cnmbr) %>% 
    assert(is_uniq, cod_muni) %>% 
    arrange(desc({{var_score}})) %>% 
    slice(1:10) %>% 
    ggplot(aes(x = fct_reorder(mpio_cnmbr, {{var_score}}, .desc = FALSE),
               y = {{var_score}})) +
    geom_bar(stat = "identity", fill = "#f8c952") +
    coord_flip() +
    theme_minimal() +
    labs(x = "mpio_cnmbr")
  
  return(graph_barr)
}

graph_scatter <- function(df, x_var, y_var) {
  
  graph <- df %>% 
    ggplot(aes(x = {{x_var}}, y = {{y_var}})) + 
    geom_point(size=1.5, color="#f8c952") +
    theme_minimal()
  
  return(graph)
}

log_info("load data")
table_shape_munis <- read_sf(args$munis_area) %>% 
  clean_names() %>% 
  assert(is_uniq, mpio_cdpmp) %>% 
  select(mpio_cdpmp, mpio_narea, mpio_cnmbr) %>% 
  ms_simplify(., keep = 0.01)

coca_2022 <- read_parquet(args$coca_2022)

gini_muni <- read_parquet(
  args$gini_muni) %>% 
  assert(not_na, cod_muni)

gini_borrar <- gini_muni %>% 
  select(gini, departamento, municipio)

logo <- image_read(args$logo_cepap)

log_info("filter")
gini_muni <- gini_muni %>% 
  filter(area_de_estudio == "PREDIOS RURALES PRIVADOS") %>% 
  filter(cod_muni > 5000) %>% 
  assert(is_uniq, cod_muni)

log_info("standardize values")
table_shape_munis <- table_shape_munis %>% 
  mutate(mpio_cdpmp = coerce_number(mpio_cdpmp))

gini_muni <- gini_muni %>% 
  verify(all(cod_muni %in% table_shape_munis$mpio_cdpmp))

coca_2022 <- coca_2022 %>% 
  mutate(codmpio = coerce_number(codmpio)) %>% 
  verify(all(codmpio %in% table_shape_munis$mpio_cdpmp))

log_info("join and clean values")
n_gini_muni <- nrow(gini_muni)

gini_muni <- gini_muni %>% 
  left_join(coca_2022, by = c("cod_muni" = "codmpio")) %>% 
  left_join(table_shape_munis, by = c("cod_muni" = "mpio_cdpmp")) %>% 
  verify(nrow(.) == n_gini_muni) %>% 
  mutate(anio_2022 = case_when(is.na(anio_2022) ~ 0, TRUE ~ anio_2022)) %>% 
  mutate(prop_coca = anio_2022/(mpio_narea*100)) %>% 
  mutate(prop_coca = round(prop_coca, 5))

log_info("process")
gini_muni_coca_0 <- gini_muni %>% 
  filter(anio_2022 > 0) %>% 
  filter(gini > 0)

log_info("lineal models")
corr_1 <- cor(gini_muni$gini, gini_muni$anio_2022)

corr_2 <- cor(gini_muni_coca_0$gini, gini_muni_coca_0$anio_2022)

na_preuba <- gini_muni %>% 
  filter(is.na(prop_coca))

corr_3 <- cor(gini_muni$gini, gini_muni$prop_coca)

corr_4 <- cor(gini_muni_coca_0$gini, gini_muni_coca_0$prop_coca)

log_info("graphs")
graph_map_gini <- plot_map(table_shape_munis, gini_muni, gini)

graph_map_coca <- plot_map(table_shape_munis, gini_muni_coca_0, anio_2022)

graph_map_coca_prop <- plot_map(table_shape_munis, gini_muni_coca_0, prop_coca)

graph_barr_top_gini <- graph_barr(gini_muni, gini)

graph_barr_top_coca <- graph_barr(gini_muni_coca_0, anio_2022)

graph_barr_top_coca_prop <- graph_barr(gini_muni_coca_0, prop_coca)

graph_scatter_gini_coca <- graph_scatter(gini_muni, gini, anio_2022)

graph_scatter_gini_coca_prop <- graph_scatter(gini_muni_coca_0, gini, prop_coca)

  
log_info("export")
ggsave(args$graph_map_gini, plot = graph_map_gini, width = 8, height = 6,
       dpi = 72)
  
ggsave(args$graph_map_coca, plot = graph_map_coca, width = 8, height = 6, dpi = 72)

ggsave(args$graph_map_coca_prop, plot = graph_map_coca_prop, width = 8, height = 6,
       dpi = 72)

ggsave(args$graph_barr_top_gini, plot = graph_barr_top_gini, width = 8,
       height = 6, dpi = 300)

ggsave(args$graph_barr_top_coca, plot = graph_barr_top_coca, width = 8,
       height = 6, dpi = 300)

ggsave(args$graph_barr_top_coca_prop, plot = graph_barr_top_coca_prop,
       width = 8, height = 6, dpi = 300)

ggsave(args$graph_scatter_gini_coca, plot = graph_scatter_gini_coca,
       width = 8, height = 6, dpi = 300)

ggsave(args$graph_scatter_gini_coca_prop, plot = graph_scatter_gini_coca_prop,
       width = 8, height = 6, dpi = 300)

log_info("done")