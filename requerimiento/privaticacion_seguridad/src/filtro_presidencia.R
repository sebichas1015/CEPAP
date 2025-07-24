
pacman::p_load(readxl, dplyr, writexl, stringr, janitor, stringi, logger, here,
                argparse, writexl, purrr, digest)

log_info("define arguments")
parser <- ArgumentParser()
parser$add_argument("--input_presdnc",
                    default = "/mnt/c/Users/sebas/OneDrive/Documentos/CEPAP/data_original/archivo/presidencia/Inventario-Documental-Archivo-Central-DAPRE.xlsx")
parser$add_argument("--output_filt",
                    default = "/mnt/c/Users/sebas/OneDrive/Documentos/CEPAP/requerimiento/privaticacion_seguridad/output/consulta_presidencia.xlsx")
args <- parser$parse_args()

df_mn <- read_excel(args$input_presdnc,
                   col_types = "text",
                   skip = 2) %>% 
  clean_names()

df_mn_fil <- df_mn %>% 
  mutate(nombre_expediente = str_to_lower(nombre_expediente)) %>% 
  mutate_if(is.character, ~stri_trans_general(., "latin-ascii"))

filtros <- "seguridad privada|convivir|vigilancia|autodefensa|paramilita"

no_filtros <- "electora|fondo de vigilancia bogota|fondo vigilancia bogota"

df_filt <- df_mn_fil %>% 
  filter(str_detect(nombre_expediente, filtros)) %>%
  filter(!(str_detect(nombre_expediente, no_filtros)))



