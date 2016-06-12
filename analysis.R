if(!require(install.load)) {install.packages("install.load"); library(install.load)}
install_load("plyr", "dplyr", "tidyr", "readr", "ggplot2", "cowplot", "MCMCglmm", "evolqg", "gdata", "devtools")

# Read data

source('R/1_read_data.R')

# Prepare data for mixed model

source('R/2_scale_data.R')
