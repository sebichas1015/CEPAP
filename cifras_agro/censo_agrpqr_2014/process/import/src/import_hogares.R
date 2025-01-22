# Authors:     SCB
# year: 2023
# =========================================

library(pacman)

p_load(here, openxlsx, dplyr, tidyr, janitor, logger, writexl,
        assertr, argparse, readr)

log_info("define arguments")
parser <- ArgumentParser()
parser$add_argument("--input_hogares",
                    default = here("data_orginal/censo_agrario/Total_nacional(csv)/S15H(Hogares).csv"))
parser$add_argument("--output_tables",
                    default = here("CO-JEP/individual-GRAI/fase4/VICTIMAS_CASO_01/clean/output/srvr.parquet"))
args <- parser$parse_args()

log_info("create functions")
ver <- function(df) {
    df_view <- bind_rows(head(df, 10), tail(df, 10))
    View(df_view)
}

log_info("load data")
hogrs <- read_delim(args$input_hogares, delim = ",") %>% 
  clean_names()


log_info("export")
write_xlsx(na_vsx_sistmtscn, export_na_sistmtzcn)

write_xlsx(na_vsx_infrms, export_na_infrms)

log_info("done.")
