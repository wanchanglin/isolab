#!/bin/bash
# wl-11-04-2018, Wed: Rscript test code
# wl-24-03-2019, Sun: change 'yes' or 'no' for --grp_file_sel
 
Rscript --vanilla ../isolab.R \
  --peak_file "../test-data/xcms.tsv" \
  --targ_file "../test-data/xcms_tar_1.tsv" \
  --grp TRUE \
  --grp_file_sel "yes" \
  --grp_file "../test-data/xcms_grp.tsv" \
  --pattern_plot TRUE \
  --residual_plot TRUE \
  --result_plot TRUE \
  --pattern_file "../test-data/res/xcms_pattern_1.pdf" \
  --residual_file "../test-data/res/xcms_residual_1.pdf" \
  --result_file "../test-data/res/xcms_result_1.pdf" \
  --summary_file "../test-data/res/xcms_summary_1.xlsx" \
  --summary_grp_file "../test-data/res/xcms_summary_grp_1.xlsx"\
