
pacman::p_load(openxlsx, dplyr, writexl, stringr, janitor, stringi)

path <- "/Users/sebas/OneDrive/Documents/curso_r_cs/input_data/archivo_historico/Catálogo Min Interior 1948-2003.xlsx"

df_mn <- read.xlsx(path) %>% 
  clean_names()

df_mn_fil <- df_mn %>% 
  mutate(asunto_o_tema = str_to_lower(asunto_o_tema)) %>% 
  mutate_if(is.character, ~stri_trans_general(., "latin-ascii"))
  
filtros <- "seguridad privada|convivir|vigilancia|privatizacion|coopetativa de vigilancia|connivencia"

no_filtros <- "electora|fondo de vigilancia bogota"

df_filt <- df_mn_fil %>% 
  filter(str_detect(asunto_o_tema, filtros)) %>%
  filter(!(str_detect(asunto_o_tema, no_filtros)))
