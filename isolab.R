## wl-20-02-2018, Tue: commence
## wl-24-02-2018, Sat: Not install. Directly use package source code
## wl-03-04-2018, Tue: Abandon `xcms` and use directly `csv` or `tsv` data
## formats
## wl-10-04-2018, Tue: substantial changes.
## ----------------------------------------------------------------------
## To-DO: 
##  2.) test single row data frame
##  3.) command lines
## ======================================================================

rm(list=ls(all=T))

## flag for command-line use or not. If false, only for debug interactively.
com_f  <- F

## ------------------------------------------------------------------------
## galaxy will stop even if R has warning message
options(warn=-1) ## disable R warning. Turn back: options(warn=0)

## ------------------------------------------------------------------------
## Setup R error handling to go to stderr
## options( show.error.messages=F, error = function (){
##   cat( geterrmessage(), file=stderr() )
##   q( "no", 1, F )
## })

# we need that to not crash galaxy with an UTF8 error on German LC settings.
loc <- Sys.setlocale("LC_MESSAGES", "en_US.UTF-8")

suppressPackageStartupMessages({
  library(optparse)
  library(WriteXLS)
  library(ecipex)
  library(gsubfn)        ## Only for function strapply
})

setwd("C:/R_lwc/isolab")
source("all_IsotopicLabelling.R")

plot_patterns  <- T
plot_residuals <- T
plot_results   <- T
save_results   <- T
group_results  <- T
groups         <- factor(c(rep("C12",4), rep("C13",4)))

## Load peak table
peak <- read.table("./test-data/xcms_obj.tsv", header = T, sep = "\t", 
                   fill = T,stringsAsFactors = F)

## Load batch parameters
targets <- read.table("./test-data/targets.tsv", header = T, sep = "\t", 
                   fill = T,stringsAsFactors = F)

## transpose data frame
targets  <- as.data.frame(t(targets))
## targets  <- as.data.frame(t(targets),stringsAsFactors = F)
## targets  <- as.list(targets)

## batch process
res_bat <- lapply(targets,function(x){ ## x = targets[[1]] 

  info <- isotopic_information(compound  = as.character(x["compound"]),
                              charge    = as.numeric(as.character(x["charge"])),
                              labelling = as.character(x["labelling"]))

  patterns <- isotopic_pattern(peak_table  = peak,
                              info        = info,
                              mass_shift  = as.numeric(as.character(x["mass_shift"])),
                              RT          = as.numeric(as.character(x["RT"])),
                              RT_shift    = as.numeric(as.character(x["RT_shift"])),
                              chrom_width = as.numeric(as.character(x["chrom_width"])))

  res <- find_abundance(patterns          = patterns,
                        info              = info,
                        initial_abundance = as.numeric(as.character(x["initial_abundance"])),
                        charge            = as.numeric(as.character(x["charge"])))

  return(res)
})
names(res_bat) <- as.character(unlist(targets[2,]))

## ---------------------------------------------------------------------- 
## Process the results
## ---------------------------------------------------------------------- 

## Plots
if (plot_patterns) {
  lapply(res_bat, function(x) plot(x=x, type="patterns", saveplots=T))
}

if (plot_residuals) {
  lapply(res_bat, function(x) plot(x=x, type="residuals", saveplots=T))
}

if (plot_results) {
  lapply(res_bat, function(x) plot(x=x, type="summary", saveplots=T))
}

## Summary of individual sample
summ  <- lapply(res_bat, function(x) as.data.frame(summary(x)))
WriteXLS(summ, ExcelFileName = "Smmary.xls", row.names = T, FreezeRow = 1)

## Summary of grouped samples
if (group_results) {
  summ_grp  <- lapply(res_bat, function(x){
    group_labelling(x, groups=groups)                      
  })
  WriteXLS(summ_grp, ExcelFileName = "Smmary_Group.xls", row.names = T, 
           FreezeRow = 1)
}

## =======================================================================
if (F) {

  info <- isotopic_information(compound="X40H77NO8P", labelling="C")
  names(info)  
  info$isotopes

  patterns <- isotopic_pattern(peak, info, mass_shift=0.05,
                               RT=285, RT_shift=20, chrom_width=7) 
  ## View(patterns)       

  fitted <- find_abundance(patterns=patterns, info=info,
                           initial_abundance=NA, charge=1)

  ## Or use wrapper function
  fitted <- main_labelling(peak, compound="X40H77NO8P", 
                           charge=1, labelling="C", mass_shift=0.05, 
                           RT=285, RT_shift=20, chrom_width=7, 
                           initial_abundance=NA)

  names(fitted)
  summary(fitted)

  save_labelling(fitted)

  ## Plot
  plot(x=fitted, type="patterns", saveplots=F)
  plot(x=fitted, type="residuals", saveplots=F)
  plot(x=fitted, type="summary", saveplots=F)

  ## Group the samples and obtain grouped estimates
  grp_est <- group_labelling(fitted,groups=factor(c(rep("C12",4), rep("C13",4))))
  grp_est 

  ## Batch-process
  bat_grp_est <- batch_labelling(peak_table=peak, targets=targets,
                                 groups=factor(c(rep("C12",4), rep("C13",4))),
                                 plot_patterns=F, plot_residuals=F,
                                 plot_results=F, save_results=T)
  bat_grp_est

  ## -----------------------------------------------------------------------
  ## Use data set from xcms
  ## -----------------------------------------------------------------------
  ## library(xcms)
  ## load("./test-data/xcms_obj.rda") ## data("xcms_obj")
  ## peak <- table_xcms(xcms_obj)
  ## write.table(peak, file="./test-data/xcms_obj.tsv", sep = "\t",
  ##             row.names = FALSE, quote = FALSE) 

  ## ------------------------------------------------------------------------
  ## Get the example data frame containing target abalytes
  # load("./test-data/targets.rda") ## data("targets")
  # write.table(targets,file="./test-data/targets.tsv", sep="\t",
  #             row.names = FALSE, quote = FALSE) 

  ## ------------------------------------------------------------------------
  ## para  <- c("compound", "charge", "labelling", "RT", "RT_shift", 
  ##            "chrom_width", "mass_shift", "initial_abundance")
  ## targets <- targets[,para]

  ## ------------------------------------------------------------------------
  ## res <- main_labelling(peak_table        = peak,
  ##                       compound          = as.character(x["compound"]),
  ##                       charge            = as.numeric(as.character(x["charge"])),
  ##                       labelling         = as.character(x["labelling"]),
  ##                       mass_shift        = as.numeric(as.character(x["mass_shift"])),
  ##                       RT                = as.numeric(as.character(x["RT"])),
  ##                       RT_shift          = as.numeric(as.character(x["RT_shift"])),
  ##                       chrom_width       = as.numeric(as.character(x["chrom_width"])),
  ##                       initial_abundance = as.numeric(as.character(x["initial_abundance"])))

  ## summ     <- lapply(res_bat,"[[","summary")
}

