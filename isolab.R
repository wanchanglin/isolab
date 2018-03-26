## wl-20-02-2018, Tue: commence
## wl-24-02-2018, Sat: Not install. Directly use package source code
## ======================================================================
## Notes:
## 
library(xcms)
library(ecipex)
library(gsubfn)        ## Only for function strapply
setwd("C:/R_lwc/isolab")
source("all_IsotopicLabelling.R")

## ------------------------------------------------------------------------
load("./test-data/xcms_obj.rda") ## data("xcms_obj")
peak_table <- table_xcms(xcms_obj)

info <- isotopic_information(compound="X40H77NO8P", labelling="C")
names(info)               ## "compound" "isotopes" "target" "nX" "nTOT"    
info$isotopes

experimental_patterns <- isotopic_pattern(peak_table, info, mass_shift=0.05,
                                          RT=285, RT_shift=20, chrom_width=7)
dim(experimental_patterns)        ## 43 10 

fitted_abundances <- find_abundance(patterns=experimental_patterns, info=info,
                                    initial_abundance=NA, charge=1)
names(fitted_abundances)

## ------------------------------------------------------------------------
## Quickly look at the results
summary(object=fitted_abundances)

## Plot the patterns
plot(x=fitted_abundances, type="patterns", saveplots=F)
## Plot the residuals
plot(x=fitted_abundances, type="residuals", saveplots=F)
## Plot the overall results
plot(x=fitted_abundances, type="summary", saveplots=F)

## Save the results to a *.csv file
save_labelling(fitted_abundances)

## =======================================================================
if (F) {
  ## ------------------------------------------------------------------------
  ## wl-20-02-2018, Tue: or use wrapper function
  fitted_abundances <- main_labelling(peak_table, compound="X40H77NO8P", 
                                      charge=1, labelling="C", mass_shift=0.05, 
                                      RT=285, RT_shift=20, chrom_width=7, 
                                      initial_abundance=NA)

  ## Group the samples and obtain grouped estimates
  grouped_estimates <- 
    group_labelling(fitted_abundances,
                    groups=factor(c(rep("C12",4), rep("C13",4))))
  grouped_estimates 

  ## ------------------------------------------------------------------------
  ## Get the example data frame containing target abalytes
  load("./test-data/targets.rda") ## data("targets")
  targets

  ## Batch-process the data
  batch_grouped_estimates <-  
    batch_labelling(targets=targets,
                    groups=factor(c(rep("C12",4), rep("C13",4))),
                    plot_patterns=FALSE, plot_residuals=FALSE,
                    plot_results=FALSE, save_results=FALSE)
  batch_grouped_estimates

}

