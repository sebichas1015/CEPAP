
pacman::p_load(openxlsx, dplyr, writexl, stringr, janitor, stringi)

path <- "/Users/sebas/OneDrive/Documents/curso_r_cs/input_data/archivo_historico/Inventario-Documental-Archivo-Central-DAPRE.xlsx"

df_mn <- read.xlsx(path, startRow = 3) %>% 
  clean_names()

df_mn_fil <- df_mn %>% 
  mutate(nombre_expediente = str_to_lower(nombre_expediente)) %>% 
  mutate_if(is.character, ~stri_trans_general(., "latin-ascii"))

filtros <- "seguridad privada|convivir|vigilancia|privatizacion|coopetativa de vigilancia|connivencia"

no_filtros <- "electora|fondo de vigilancia bogota"

df_filt <- df_mn_fil %>% 
  filter(str_detect(nombre_expediente, filtros)) %>%
  filter(!(str_detect(nombre_expediente, no_filtros)))
