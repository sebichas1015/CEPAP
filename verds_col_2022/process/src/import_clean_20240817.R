#
# Authors:     Sebas and Nicholas
# Maintainers: Sebas and Nicholas
# Year: 2024
# =========================================

pacman::p_load(readr, dplyr, tidyr, janitor, logger, assertr, purrr, arrow,
               digest, writexl, sf)

if(dir.exists("/Users/sebas/OneDrive")) {
  
  input_1 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/verds_col_2022/process/input/Veredas_de_Colombia/Veredas_de_Colombia.shp"
  
  input_2 <- "C:/Users/sebas/OneDrive/Documents/repositorio_cepap/CEPAP/verds_col_2022/process/output/shapefile.veredas.arrow"
  
  output_1 <- "/Users/sebas/OneDrive/Documents/CEPAP/censo_agropecuarios_2014/Total_nacional(csv)/code_censo_agr_2014/output/resultados_incononzo_castillo.xlsx"
} else {
  input_1 <- "/Users/ruta_nico"
  
  output_2 <- "/Users/ruta_nico"
}

log_info("load data")
ir <- read_sf(input_1) %>% 
  clean_names()

