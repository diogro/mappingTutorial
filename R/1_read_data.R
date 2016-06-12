# Read phenotype data

raw_phenotype = read_csv("./data/raw/phenotype_data.csv")

# Read marker data

raw_marker = read_csv("./data/raw/marker_data.csv")

# First let's join both raw_ data object in a single data.frame, using the ID column as a key

## Inner join will only keep rows that are present in both  data.frames
## See other options here: https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf
area_data = inner_join(raw_phenotype, raw_marker, by = "ID")

# let's save this processed object:
write_csv(area_data, "./data/processed/phen_marker_data.csv")

# Avoid clutering the workspace
rm(list = ls(pattern='raw_'))
