## wl-20-02-2018, Tue: commence

library(IsotopicLabelling)
## ------------------------------------------------------------------------
data("xcms_obj")
peak_table <- table_xcms(xcms_obj)
peak_table[57:59,]

info <- isotopic_information(compound="X40H77NO8P", labelling="C")
## attributes(info)
names(info)               ## "compound" "isotopes" "target" "nX" "nTOT"    
info$isotopes

experimental_patterns <- isotopic_pattern(peak_table, info, mass_shift=0.05,
                                          RT=285, RT_shift=20, chrom_width=7)
dim(experimental_patterns)        ## 43 10 
head(experimental_patterns)

fitted_abundances <- find_abundance(patterns=experimental_patterns, info=info,
                                    initial_abundance=NA, charge=1)
attributes(fitted_abundances)
## $names
## [1] "compound"      "best_estimate" "std_error"     "dev_percent"  
## [5] "x_scale"       "y_exp"         "y_theor"       "residuals"    
## [9] "warnings"     

## $class
## [1] "labelling"

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

## ------------------------------------------------------------------------
## wl-20-02-2018, Tue: wrapper function
fitted_abundances <- main_labelling(peak_table, compound="X40H77NO8P", 
                                    charge=1, labelling="C", mass_shift=0.05, 
                                    RT=285, RT_shift=20, chrom_width=7, 
                                    initial_abundance=NA)

## ------------------------------------------------------------------------
## Group the samples and obtain grouped estimates
grouped_estimates <- 
  group_labelling(fitted_abundances,
                  groups=factor(c(rep("C12",4), rep("C13",4))))
grouped_estimates 
## wl-20-02-2018, Tue: what is his for?

## ------------------------------------------------------------------------
## Get the example data frame containing target abalytes
data("targets")
targets

## Batch-process the data
## wl-20-02-2018, Tue: problem.
batch_grouped_estimates <- 
  batch_labelling(targets=targets,
                  groups=factor(c(rep("C12",4), rep("C13",4))),
                  plot_patterns=FALSE, plot_residuals=FALSE,
                  plot_results=FALSE, save_results=FALSE)


