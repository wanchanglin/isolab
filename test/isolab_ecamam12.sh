#!/bin/bash
# wl-27-03-2019, Wed: for ecamam12 data 

Rscript --vanilla ../isolab.R \
  --peak_file "../test-data/ecamam12.tsv" \
  --targ_file "../test-data/ecamam12_tar.tsv" \
  --grp TRUE \
  --grp_file_sel "no" \
  --grp_file "../test-data/ecamam12_grp.tsv" \
  --groups  "12C_Lys,12C_Lys,12C_Lys,12C_Glu,12C_Glu,12C_Glu,12C_Lys, 12C_Lys,12C_Lys,13C_Lys,13C_Lys,13C_Lys,12C_Glu,12C_Glu, 12C_Glu,13C_Glu,13C_Glu,13C_Glu,12C_Lys,12C_Lys,12C_Lys, 13C_Lys,13C_Lys,13C_Lys,12C_Glu,12C_Glu,12C_Glu,13C_Glu, 13C_Glu,13C_Glu,12C_Lys,12C_Lys,12C_Lys,13C_Lys,13C_Lys, 13C_Lys,12C_Glu,12C_Glu,12C_Glu,13C_Glu,13C_Glu,13C_Glu" \
  --pattern_plot TRUE \
  --residual_plot TRUE \
  --result_plot TRUE \
  --pattern_file "../test-data/res/ecamam12_pattern.pdf" \
  --residual_file "../test-data/res/ecamam12_residual.pdf" \
  --result_file "../test-data/res/ecamam12_result.pdf" \
  --summary_file "../test-data/res/ecamam12_summary.tsv" \
  --summary_grp_file "../test-data/res/ecamam12_summary_grp.tsv"\
