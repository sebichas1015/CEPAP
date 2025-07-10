#
# Authors:     Sebas
# Maintainers: Sebas
# Year: 2024
# =========================================

pacman::p_load(sf, dplyr, arrow, stringr, logger)

log_info("define paths")
path <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/munis_col_2023/input/MGN2023_MPIO_POLITICO/MGN_ADM_MPIO_GRAFICO.shp"

path_output <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/munis_col_2023/output/munis_clean.parquet"

log_info("load data")
muni_2023 <- st_read(path)

log_info("clean")
muni_2023 <- muni_2023 %>% 
  select(-geometry, -shape_Area, -shape_Leng, -mpio_narea, -mpio_crslc)

muni_export <- data.frame(dpto_code = muni_2023$dpto_ccdgo,
                          dpto_name = muni_2023$dpto_cnmbr,
                          muni_code = muni_2023$mpio_ccdgo,
                          muni_name = muni_2023$mpio_cnmbr)

log_info("write")
write_parquet(muni_export, path_output)
#done.