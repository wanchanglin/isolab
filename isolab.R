## wl-20-02-2018, Tue: commence
## wl-24-02-2018, Sat: Not install. Directly use package source code
## wl-03-04-2018, Tue: Abandon `xcms` and use directly `csv` or `tsv` data
## formats
## wl-10-04-2018, Tue: substantial changes.
## wl-11-04-2018, Wed: command line and change plot function
## ----------------------------------------------------------------------
## To-DO: 
##  1.) XML file and repeat input in Galaxy
##  2.) test single row data frame
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

if(com_f){

  ## -----------------------------------------------------------------------
  ## Setup home directory
  ## wl-24-11-2017, Fri: A dummy function for the base directory. The reason
  ## to write such a function is to keep the returned values by
  ## 'commandArgs' with 'trailingOnly = FALSE' in a local environment
  ## otherwise 'parse_args' will use the results of
  ## 'commandArgs(trailingOnly = FALSE)' even with 'args =
  ## commandArgs(trailingOnly = TRUE)' in its argument area.
  func <- function(){
    argv <- commandArgs(trailingOnly = FALSE)
    path <- sub("--file=","",argv[grep("--file=",argv)])
  }
  ## prog_name <- basename(func())
  tool_dir <- paste0(dirname(func()),"/")

  option_list <- 
    list(
         make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
                     help="Print extra output [default]"),
         make_option(c("-q", "--quietly"), action="store_false",
                     dest="verbose", help="Print little output"),

         ## -------------------------------------------------------------------
         ## input files
         make_option("--peak_file", type="character",
                     help="Peak table with m/z, retention time and intensity"),
         make_option("--targ_file", type="character",
                     help="Parameter data metrix in which each row is one 
                           instance of setting for ananlysis"),

         ## group abundance estimate
         make_option("--grp", type="logical", default=TRUE,
                     help="Apply group estimates of abundance"), 
         make_option("--groups",type="character",
                     help="Group information for samples"),
                     
         ## plot output
         make_option("--pattern_plot", type="logical", default=TRUE,
                     help="Plot patterns"),
         make_option("--residual_plot", type="logical", default=TRUE,
                     help="Plot residuals"),
         make_option("--result_plot", type="logical", default=TRUE,
                     help="Plot results"),

         ## pdf files 
         make_option("--pattern_file",type="character", default="pattern.pdf",
                     help="Save pattern plot"),
         make_option("--residual_file",type="character", default="residual.pdf",
                     help="Save residual plot"),
         make_option("--result_file",type="character", default="result.pdf",
                     help="Save result plot"),

         ## Excel files 
         make_option("--summary_file",type="character",default="summary.xls",
                     help="Save summary results in Excel"),
         make_option("--summary_grp_file",type="character",
                     default="summary_grp.xls",
                     help="Save group summary results")
         )

  opt <- parse_args(object=OptionParser(option_list=option_list),
                    args = commandArgs(trailingOnly = TRUE))
  ## print(opt)

} else {
  ## tool_dir <- "C:/R_lwc/isolab/"         ## for windows
  tool_dir <- "~/my_galaxy/isolab/"  ## for linux. must be case-sensitive
  opt  <- list(
               ## input files
               peak_file    = paste0(tool_dir,"test-data/xcms_obj.tsv"),
               targ_file    = paste0(tool_dir,"test-data/targets.tsv"),

               ## group abundance estimate
               grp            = "TRUE",
               groups        = "C12,C12,C12,C12,C13,C13,C13,C13",

               ## plot output
               pattern_plot  = TRUE,
               residual_plot = TRUE,
               result_plot   = TRUE,

               ## pdf files 
               pattern_file  = paste0(tool_dir,"res/pattern.pdf"),
               residual_file = paste0(tool_dir,"res/residual.pdf"),
               result_file   = paste0(tool_dir,"res/result.pdf"),

               ## Excel files 
               summary_file     = paste0(tool_dir,"res/summary.xls"),
               summary_grp_file = paste0(tool_dir,"res/summary_grp.xls")
               )

}

suppressPackageStartupMessages({
  source(paste0(tool_dir,"all_IsotopicLabelling.R"))
})

## Load peak table
peak <- read.table(opt$peak_file, header = T, sep = "\t", 
                   fill = T,stringsAsFactors = F)

## Load batch parameters
targets <- read.table(opt$targ_file, header = T, sep = "\t", 
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
if (opt$pattern_plot) {
  pdf(file = opt$pattern_file, onefile = T,width=15, height=10)
  lapply(res_bat, function(x) plot.func(x=x, type="patterns"))
  dev.off()
}


if (opt$residual_plot) {
  pdf(file = opt$residual_file, onefile = T,width=15, height=10)
  lapply(res_bat, function(x) plot.func(x=x, type="residuals"))
  dev.off()
}

if (opt$result_plot) {
  pdf(file = opt$result_file, onefile = T,width=15, height=10)
  lapply(res_bat, function(x) plot.func(x=x, type="summary"))
  dev.off()
}

## Summary of individual sample
summ  <- lapply(res_bat, function(x) as.data.frame(summary(x)))
WriteXLS(summ, ExcelFileName = opt$summary_file, row.names = T, FreezeRow = 1)

## Summary of grouped samples
if (opt$grp) {
  ## process group information
  groups <- opt$groups
  groups <- unlist(strsplit(groups,","))
  groups <- gsub("^[ \t]+|[ \t]+$", "", groups)  ## trim white spaces
  groups <- factor(groups)

  summ_grp <- lapply(res_bat, function(x) group_labelling(x, groups = groups))
  WriteXLS(summ_grp, ExcelFileName = opt$summary_grp_file, row.names = T, 
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

