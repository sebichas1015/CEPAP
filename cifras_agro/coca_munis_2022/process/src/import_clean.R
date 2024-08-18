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
parser$add_argument("--table_coca",
                    default = "cifras_agro/coca_munis_2022/process/input/RPT_CultivosIlicitos_2024-08-18--005524.xlsx")
parser$add_argument("--output_result",
                    default = "cifras_agro/coca_munis_2022/process/output/coca_2022_clean.parquet")
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
coca_2022 <- read.xlsx(args$table_coca, sheet = 1, startRow = 9,
                       colNames = TRUE) %>% 
  clean_names()

log_info("clean and select colnames")
coca_2022 <- coca_2022 %>% 
  rename(anio_2022 = x2022) %>% 
  select(coddepto, departamento, codmpio, municipio, anio_2022)

log_info("standadize values")
coca_2022 <- coca_2022 %>% 
  filter(!(str_detect(coddepto, "Total"))) %>% 
  filter(!(str_detect(coddepto, "Fuente"))) %>%
  assert(not_na, everything()) %>% 
  mutate(anio_2022 = coerce_number(anio_2022))

log_info("export")
write_parquet(coca_2022, args$output_result)

rm(coca_2022)
gc()

log_info("done import_clean.R")