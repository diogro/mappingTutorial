# Read phenotype data

raw_phenotype = read_csv("./data/raw/phenotype_data.csv")

# Read marker data

raw_marker = read_csv("./data/raw/marker_data.csv")

# First let's join both raw_ data object in a single data.frame, using the ID column as a key

## Inner join will only keep rows that are present in both  data.frames
area_data = inner_join(raw_phenotype, raw_marker, by = "ID")

# Avoid clutering the workspace
rm(list = ls(pattern='raw_'))
