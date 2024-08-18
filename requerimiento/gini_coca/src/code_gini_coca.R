#
# Authors:     SCB
# Maintainers: SCB
# Copyright: 2024, JEP, GPL or newer
# =========================================
# CO-JXXXXXXXXXX

pacman::p_load(argparse, here, dplyr, logger, arrow, assertr, openxlsx, janitor,
               tidyr, stringr)

setwd("/Users/sebas/OneDrive/Documents/CEPAP/team_data/")

parser <- ArgumentParser()
parser$add_argument("--coca_2022",
                    default = "cifras_agro/coca_munis_2022/process/output/coca_2022_clean.parquet")
parser$add_argument("--gini_muni",
                    default = "cifras_agro/igac_gini/process/output/gini_igac.parquet")
parser$add_argument("--munis_area",
                    default = "munis_col_2021/process/output/shapefile_munis.arrow")
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
coca_2022 <- read_parquet(args$coca_2022)

gini_muni <- read_parquet(args$gini_muni,
                          col_select = all_of(c("cod_muni", "gini", "area_de_estudio")))

log_info("filter")
gini_muni <- gini_muni %>% 
  filter(area_de_estudio == "PREDIOS RURALES PRIVADOS") %>% 
  assert(is_uniq, cod_muni)

log_info("standardize values")
coca_2022 <- coca_2022 %>% 
  mutate(codmpio = coerce_number(codmpio))

log_info("join and clean values")
n_gini_muni <- nrow(gini_muni)

gini_muni <- gini_muni %>% 
  left_join(coca_2022, by = c("cod_muni" = "codmpio")) %>% 
  verify(nrow(.) == n_gini_muni) %>% 
  mutate(anio_2022 = case_when(is.na(anio_2022) ~ 0, TRUE ~ anio_2022))

prueba <- gini_muni %>% 
  filter(anio_2022 > 0) %>% 
  filter(gini > 0)

lm_1 <- lm(gini_muni$gini ~gini_muni$anio_2022)

lm_2 <- lm(prueba$gini ~prueba$anio_2022)






