# -*- coding: utf-8 -*-
"""
Created on Fri Nov  8 21:44:54 2024

@author: sebas
"""

import polars as pl

import os

path_uph = "/Users/sebas/OneDrive/Documents/CEPAP/team_data/data_orginal/cnmh/"

list_paths = os.listdir(path_uph)

uph3 = pl.read_parquet(path_uph, columns=vars_perp)

uph3_perp = uph3.filter(pl.col("tipo_sujeto") == "PRESUNTO RESPONSABLE")

uph3_vict = uph3.filter(pl.col("tipo_sujeto") == "VICTIMA")

names_uph = pl.concat([uph3_perp, uph3_vict])

del uph3, uph3_perp, uph3_vict

names_uph.with_columns(
    pl.col("nombre_apellido_completo")
    .str.len_chars()
    .alias("long_names")
)

count_dist_uph = names_uph.group_by("match_group_id").agg([
    pl.col("dane_mpio_hecho").n_unique().alias("n_mpio"),
    pl.col("dane_dpto_hecho").n_unique().alias("n_dpto"),
    pl.col("yy_hecho_inicial").n_unique().alias("n_year"),
    pl.col("tipo_hecho").n_unique().alias("n_th"),
    pl.col("recordid").n_unique().alias("n_regs"),
    pl.col("exact_id").n_unique().alias("n_exact"),
    pl.col("cedula").n_unique().alias("n_docs"),
    pl.col("nombre_apellido_completo").n_unique().alias("n_names")
])



