if(!require(install.load)) {install.packages("install.load"); library(install.load)}
install_load("plyr", "dplyr", "tidyr", "readr", "ggplot2", "cowplot", "MCMCglmm", "evolqg", "gdata", "devtools")

# Read data
source('R/1_read_data.R')

# Prepare data for mixed model by removing fixed effects
source('R/2_scale_data.R')

# Verify everything is ok using some plots
source('R/3_diagnostics_plots.R')

# Set up the mapping

## first the null model, with no markers
source('R/4_run_null_model.R')

## now the marker models
install_load("doParallel"); registerDoParallel(cores = 3)
source('R/5_run_single_marker_model.R')