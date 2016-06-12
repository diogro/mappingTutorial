if(!require(install.load)) {install.packages("install.load"); library(install.load)}
install_load("plyr", "dplyr", "tidyr", "readr", "ggplot2", "cowplot", "MCMCglmm", "evolqg", "gdata", "devtools")

# Read data

source('./R/read_data.R')
