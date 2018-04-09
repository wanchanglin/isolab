## wl-20-02-2018, Tue: commence
## wl-24-02-2018, Sat: Not install. Directly use package source code
## ======================================================================
## Notes:
##   2.) 
library(ecipex)
library(gsubfn)        ## Only for function strapply
setwd("C:/R_lwc/isolab")
source("all_IsotopicLabelling.R")

plot_patterns  <- F
plot_residuals <- F
plot_results   <- F
save_results   <- F
groups         <- factor(c(rep("C12",4), rep("C13",4)))

## Load peak table
peak <- read.table("./test-data/xcms_obj.tsv", header = T, sep = "\t", 
                   fill = T,stringsAsFactors = F)

## Load batch parameters
targets <- read.table("./test-data/targets.tsv", header = T, sep = "\t", 
                   fill = T,stringsAsFactors = F)

## para  <- c("compound", "charge", "labelling", "RT", "RT_shift", 
##            "chrom_width", "mass_shift", "initial_abundance")
## targets <- targets[,para]

## attach targets data frame
targets  <- as.data.frame(t(targets))
## targets  <- as.data.frame(t(targets),stringsAsFactors = F)
## targets  <- as.list(targets)

res_bat  <- lapply(targets,function(x){
    ## x = targets[[1]] 

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

    ## res <- main_labelling(peak_table        = peak,
    ##                       compound          = as.character(x["compound"]),
    ##                       charge            = as.numeric(as.character(x["charge"])),
    ##                       labelling         = as.character(x["labelling"]),
    ##                       mass_shift        = as.numeric(as.character(x["mass_shift"])),
    ##                       RT                = as.numeric(as.character(x["RT"])),
    ##                       RT_shift          = as.numeric(as.character(x["RT_shift"])),
    ##                       chrom_width       = as.numeric(as.character(x["chrom_width"])),
    ##                       initial_abundance = as.numeric(as.character(x["initial_abundance"])))


    if (plot_patterns) plot(x=res, type="patterns", saveplots=T)
    if (plot_residuals) plot(x=res, type="residuals", saveplots=T)
    if (plot_results) plot(x=res, type="summary", saveplots=T)
    if (save_results) save_labelling(res)

    ## Group the samples and obtain grouped estimates
    group_labelling(res, groups=groups)

})
## names(res_bat) <- factor(targets[1,,drop=T])
## wl-09-04-2018, Mon: problem here


info <- isotopic_information(compound="X40H77NO8P", labelling="C")
names(info)  
info$isotopes

patterns <- isotopic_pattern(peak, info, mass_shift=0.05,
                             RT=285, RT_shift=20, chrom_width=7) ## TR=285
## View(patterns)       

fitted <- find_abundance(patterns=patterns, info=info,
                         initial_abundance=NA, charge=1)
names(fitted)
summary(fitted)

## Plot the patterns
plot(x=fitted, type="patterns", saveplots=T)
plot(x=fitted, type="residuals", saveplots=T)
plot(x=fitted, type="summary", saveplots=T)

## Group the samples and obtain grouped estimates
grp_est <- group_labelling(fitted,groups=factor(c(rep("C12",4), rep("C13",4))))
grp_est 


## Batch-process the data
bat_grp_est <- batch_labelling(peak_table=peak, targets=targets,
                               groups=factor(c(rep("C12",4), rep("C13",4))),
                               plot_patterns=F, plot_residuals=F,
                               plot_results=F, save_results=T)
bat_grp_est


## =======================================================================
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

