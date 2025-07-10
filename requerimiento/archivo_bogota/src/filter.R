#
# Authors:     Sebas
# Maintainers: Sebas
# Year: 2024
# =========================================

pacman::p_load(openxlsx, dplyr, stringr, stringi, janitor, purrr, logger, writexl)

path <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/requerimiento/archivo_bogota/input/ISAD (G) Planos Departamento Administrativo de Acción Comunal VF.xlsx"

path_output <- "/Users/sebas/OneDrive/Documents/CEPAP/team_data/requerimiento/archivo_bogota/output/filtros.xlsx"

log_info("create functions")
hash_ids <- function(data_frame) {
  pmap(data_frame, list) %>%
    map_chr(., digest, algo = "sha1")
}

df <- read.xlsx(path) 

log_info("clean")
df_filter <- df %>% 
  clean_names() %>%
  mutate_all(~str_squish(.)) %>%
  mutate_if(is.character, ~stri_trans_general(., "latin-ascii")) %>% 
  mutate_if(is.character, ~ str_to_lower(.))

key_words <- "legalizac|conflict|lucha|formaliza|informa|invasio|bloqueo|vias|paro|toma|lider|popular"

df_filter <- df_filter %>% 
  filter(str_detect(alcance_y_contenido, key_words))

write_xlsx(df_filter, path_output)