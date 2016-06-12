# We need to control for fixed effects that are not important for our analysis, like sex and cohort
# We do this by using a linear model.

# Linear model funtions can either use data in wide of narrow formats, and the tidyr package can
# convert them for us.

# Let's use a narrow format for this analysis
n_area_data = gather(area_data, trait, value, area1:area7)

# Now we set up a linear model with all the fixed effects we want to remove:
area_lm = lm(value ~ trait:SEX + trait:LSB + trait:LSW + trait:COHORT, data = n_area_data)

# Create a new data.frame to hold the transformed data:
n_area_data_std = n_area_data

# Replace the original values with the transformed ones:
n_area_data_std$value = residuals(area_lm)

# And return the data to wide format and select the columns that we need:
area_data_std =
  spread(n_area_data_std, trait, value) %>%
  select(ID, FAMILY, SEX, area1:area7, A1:I5)

# We can also scale the data to unit variance
area_data_std = area_data_std %>% mutate_each(funs(scale), matches('area'))

# It will be usefull to have the data in narrow format for plotting
n_area_data_std = gather(area_data_std, trait, value, area1:area7)
