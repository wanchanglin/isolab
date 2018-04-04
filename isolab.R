## wl-20-02-2018, Tue: commence
## wl-24-02-2018, Sat: Not install. Directly use package source code
## ======================================================================
## Notes:
##   2.) 
library(ecipex)
library(gsubfn)        ## Only for function strapply
setwd("C:/R_lwc/isolab")
source("all_IsotopicLabelling.R")

## -----------------------------------------------------------------------
## Use data set from xcms
## -----------------------------------------------------------------------
## library(xcms)
## load("./test-data/xcms_obj.rda") ## data("xcms_obj")
## peak <- table_xcms(xcms_obj)
## write.table(peak, file="./test-data/xcms_obj.csv", sep = ",",
##             row.names = FALSE, quote = FALSE) 

## Load data set
peak <- read.table("./test-data/xcms_obj.csv", header = T, sep = ",", 
                   fill = T,stringsAsFactors = F)

info <- isotopic_information(compound="X40H77NO8P", labelling="C")
names(info)  
info$isotopes

patterns <- isotopic_pattern(peak, info, mass_shift=0.05,
                             RT=285, RT_shift=20, chrom_width=7) ## TR=285
View(patterns)       

fitted <- find_abundance(patterns=patterns, info=info,
                         initial_abundance=NA, charge=1)
names(fitted)
summary(fitted)

## Group the samples and obtain grouped estimates
grp_est <- group_labelling(fitted,groups=factor(c(rep("C12",4), rep("C13",4))))
grp_est 

## ------------------------------------------------------------------------
## Get the example data frame containing target abalytes
load("./test-data/targets.rda") ## data("targets")
targets

## Batch-process the data
bat_grp_est <- batch_labelling(peak_table=peak, targets=targets,
                               groups=factor(c(rep("C12",4), rep("C13",4))),
                               plot_patterns=F, plot_residuals=F,
                               plot_results=F, save_results=T)
bat_grp_est

## Plot the patterns
plot(x=fitted, type="patterns", saveplots=F)
## Plot the residuals
plot(x=fitted, type="residuals", saveplots=T)
## Plot the overall results
plot(x=fitted, type="summary", saveplots=T)


## =======================================================================
if (F) {
  ## Save the results to a *.csv file
  save_labelling(fitted)

  ## ------------------------------------------------------------------------
  ## wl-20-02-2018, Tue: or use wrapper function
  fitted <- main_labelling(peak, compound="X40H77NO8P", 
                           charge=1, labelling="C", mass_shift=0.05, 
                           RT=285, RT_shift=20, chrom_width=7, 
                           initial_abundance=NA)
}

