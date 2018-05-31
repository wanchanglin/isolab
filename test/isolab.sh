#!/bin/bash
# wl-11-04-2018, Wed: Rscript test code

  # --peak_file "./test-data/ecamam12.tsv" \
  # --targ_file "./test-data/ecamam12_tar.tsv" \
  # --group  "12C_Lys,12C_Lys,12C_Lys,12C_Glu,12C_Glu,12C_Glu,12C_Lys, 12C_Lys,12C_Lys,13C_Lys,13C_Lys,13C_Lys,12C_Glu,12C_Glu, 12C_Glu,13C_Glu,13C_Glu,13C_Glu,12C_Lys,12C_Lys,12C_Lys, 13C_Lys,13C_Lys,13C_Lys,12C_Glu,12C_Glu,12C_Glu,13C_Glu, 13C_Glu,13C_Glu,12C_Lys,12C_Lys,12C_Lys,13C_Lys,13C_Lys, 13C_Lys,12C_Glu,12C_Glu,12C_Glu,13C_Glu,13C_Glu,13C_Glu" \

Rscript --vanilla isolab.R \
  --peak_file "./test-data/xcms.tsv" \
  --targ_file "./test-data/xcms_tar.tsv" \
  --group  "C12, C12,  C12,C12,C13,C13,C13,C13" \
  --grp TRUE \
  --pattern_plot TRUE \
  --residual_plot TRUE \
  --result_plot TRUE \
  --pattern_file "./res/pattern.pdf" \
  --residual_file "./res/residual.pdf" \
  --result_file "./res/result.pdf" \
  --summary_file "./res/summary.xlsx" \
  --summary_grp_file "./res/summary_grp.xlsx"\
