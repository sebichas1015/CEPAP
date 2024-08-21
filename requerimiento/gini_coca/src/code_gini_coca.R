#
# Authors:     SCB
# Maintainers: SCB
# Copyright: 2024, JEP, GPL or newer
# =========================================
# CO-JXXXXXXXXXX

pacman::p_load(argparse, here, dplyr, logger, arrow, assertr, openxlsx, janitor,
               tidyr, stringr, sf)

setwd("/Users/sebas/OneDrive/Documents/CEPAP/team_data/")

parser <- ArgumentParser()
parser$add_argument("--coca_2022",
                    default = "cifras_agro/coca_munis_2022/process/output/coca_2022_clean.parquet")
parser$add_argument("--gini_muni",
                    default = "cifras_agro/igac_gini/process/output/gini_igac.parquet")
parser$add_argument("--munis_area",
                    default = "munis_col_2021/process/input/SHP_MGN2021_COLOMBIA/MGN_2021_COLOMBIA/ADMINISTRATIVO/MGN_MPIO_POLITICO.shp")
args <- parser$parse_args()

log_info("load functions")
coerce_number <- function(x) {
  n_na <- sum(is.na(x))
  
  x <- as.numeric(x)
  
  n_na_new <- sum(is.na(x))
  
  stopifnot(n_na == n_na_new)
  
  return(x)
}

log_info("load data")
table_shape_munis <- read_sf(args$munis_area) %>% 
  clean_names() %>% 
  assert(is_uniq, mpio_cdpmp) %>% 
  select(mpio_cdpmp, mpio_narea)

coca_2022 <- read_parquet(args$coca_2022)

gini_muni <- read_parquet(args$gini_muni,
                          col_select =
                            all_of(c("cod_muni", "gini", "area_de_estudio"))) %>% 
  assert(not_na, cod_muni)

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

prueba <- gini_muni %>% 
  filter(anio_2022 > 0) %>% 
  filter(gini > 0)

corr_1 <- cor(gini_muni$gini, gini_muni$anio_2022)

corr_2 <- cor(prueba$gini, prueba$anio_2022)

na_preuba <- gini_muni %>% 
  filter(is.na(prop_coca))

corr_3 <- cor(gini_muni$gini, gini_muni$prop_coca)

corr_4 <- cor(prueba$gini, prueba$prop_coca)

