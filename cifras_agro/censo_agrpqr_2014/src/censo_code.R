# Authors: Sebas and Nicholas
# Year: 2024

pacman::p_load(readr, dplyr, tidyr)

input_censo <- "CEPAP/Total_nacional(csv)/S01_15(Unidad_productora).csv"

prueba <- read_csv(input_censo)
