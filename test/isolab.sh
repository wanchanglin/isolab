#!/bin/bash
# wl-11-04-2018, Wed: Rscript test code

Rscript --vanilla isolab.R \
  --peak_file "./test-data/xcms_obj.tsv" \
  --targ_file "./test-data/targets.tsv" \
  --grp TRUE \
  --group  "C12,C12,C12,C12,C13,C13,C13,C13" \
  --pattern_plot TRUE \
  --residual_plot TRUE \
  --result_plot TRUE \
  --pattern_file "./res/pattern.pdf" \
  --residual_file "./res/residual.pdf" \
  --result_file "./res/result.pdf" \
  --summary_file "./res/summary.xls" \
  --summary_grp_file "./res/summary_grp.xls"\
