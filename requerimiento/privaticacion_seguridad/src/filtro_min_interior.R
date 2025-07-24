
#
# Authors:     SCB
# Maintainers: SCB
# Copyright: 2025, CEPAP
# =========================================
# requerimientos/

pacman::p_load(readxl, dplyr, writexl, stringr, janitor, stringi, logger, here,
                argparse, writexl, purrr, digest)

log_info("define arguments")
parser <- ArgumentParser()
parser$add_argument("--input_minintr",
                    default = "/mnt/c/Users/sebas/OneDrive/Documentos/CEPAP/data_original/archivo/min_interior/Catálogo Min Interior 1948-2003.xlsx")
parser$add_argument("--output_filt",
                    default = "/mnt/c/Users/sebas/OneDrive/Documentos/CEPAP/requerimiento/privaticacion_seguridad/output/consulta_min_interior.xlsx")
args <- parser$parse_args()


log_info("read data")
df_mn <- read_excel(args$input_minintr,
                   col_types = "text") %>% 
  clean_names()

df_mn_fil <- df_mn %>% 
  mutate(asunto_o_tema = str_to_lower(asunto_o_tema)) %>% 
  mutate_if(is.character, ~stri_trans_general(., "latin-ascii"))
  
filtros <- "seguridad privada|convivir|vigilancia|autodefensa|paramilita"

no_filtros <- "electora|fondo de vigilancia bogota|fondo vigilancia bogota"

df_filt <- df_mn_fil %>% 
  filter(str_detect(asunto_o_tema, filtros)) %>%
  filter(!(str_detect(asunto_o_tema, no_filtros)))

log_info("export")
write_xlsx(df_filt, args$output_filt)

log_info("done filtro_min_interior.R")
#done
