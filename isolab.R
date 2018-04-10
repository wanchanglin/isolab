## wl-20-02-2018, Tue: commence
## wl-24-02-2018, Sat: Not install. Directly use package source code
## wl-03-04-2018, Tue: Abandon `xcms` and use directly `csv` or `tsv` data
## formats
## wl-10-04-2018, Tue: substantial changes.
## ----------------------------------------------------------------------
## To-DO: 
##  1.) test single row data frame
##  2.) Modify plot function and make it accept location of file saved.
##  3.) command line
##  4.) XML file and repeat input in Galaxy
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
         make_option("--data_file", type="character",
                     help="Mass spectrometry intensity data matrix"),
         make_option("--meta_file", type="character",
                     help="Meta data including groups information"),

         ## feature selection            
         make_option("--group",type="character",
                     help="Group information in the metadata for statistical 
                     analysis."),
         make_option("--boot", type="logical", default=TRUE,
                     help="Apply bootstraping for feature selection or not."), 
         make_option("--boot_size", type="integer", default=100,
                     help="Bootstrap size"),
         make_option("--fs_method", type="character", default="fs.welch",
                     help="Multiple feature selection methods"), 
         make_option("--final_set_method", type="character", default="frequency",
                     help="Final feature set selection methods. Two methods 
                     are supported:frequency and intersection."), 
         make_option("--freq_cutoff",type="double", default = 0.5,
                     help="Cutoff of frequency for resampling. Value is in 
                     the range of 0 and 1"), 
         make_option("--top_k", type="integer", default=50,
                     help="Top-K feature number for the final feature set 
                     selection"),
         make_option("--pval_tune", type="logical", default=TRUE,
                     help="Tune the final selected features based on p-values."),
         make_option("--pval_thre",type="double", default = 0.05,
                     help="P-value threshold for the final tuning of selected features."), 

         ## plot
         ## make_option("--freq_tab", type="logical", default=TRUE,
         ##             help="Plot frequency table for the frequency method of the final
         ##                   feature subset selection. Only with bootstrap."),
         ## make_option("--venn", type="logical", default=TRUE,
         ##             help="Plot Venn diagram for intersection method of final feature
         ##             subset selection."),

         ## output
         make_option("--stats", type="logical", default=TRUE,
                     help="Save statistical summary of data set after feature selection"),
         make_option("--box", type="logical", default=TRUE,
                     help="Plot the boxplot of the selected features with p-values."),
         make_option("--pca", type="logical", default=TRUE,
                     help="Plot the PCA (unsupervised) for the selected features."),
         make_option("--pls", type="logical", default=TRUE,
                     help="Plot the PLS (supervised) for the selected features."),
         make_option("--rda", type="logical", default=TRUE,
                     help="Save all R running results."),
         make_option("--fusion_file",type="character", default="fusion.pdf",
                     help="Plot feature fusion by either frequency table or Venn diagram"),
         make_option("--data_fs_file",type="character", default="data_fs.tab",
                     help="Data set after feature selection"),
         make_option("--stats_file",type="character", default="stats.tab",
                     help="Statistical summary for the data set after feature selection."),
         make_option("--box_file",type="character",default="box.pdf"),
         make_option("--pca_file",type="character",default="pca.pdf"),
         make_option("--pls_file",type="character",default="pls.pdf"),
         make_option("--rda_file",type="character",default="R_running.rda")
         )

  opt <- parse_args(object=OptionParser(option_list=option_list),
                    args = commandArgs(trailingOnly = TRUE))
  ## print(opt)

} else {
  tool_dir <- "C:/R_lwc/isolab/"         ## for windows
  ## tool_dir <- "~/my_galaxy/isolab/"  ## for linux. must be case-sensitive
  opt  <- list(
               ## input
               peak_file    = paste0(tool_dir,"test-data/xcms_obj.tsv"),
               targ_file    = paste0(tool_dir,"test-data/targets.tsv"),

               ## feature selection parameters
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
  lapply(res_bat, function(x) plot(x=x, type="patterns", saveplots=T))
}

if (opt$residual_plot) {
  lapply(res_bat, function(x) plot(x=x, type="residuals", saveplots=T))
}

if (opt$result_plot) {
  lapply(res_bat, function(x) plot(x=x, type="summary", saveplots=T))
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

