
# MCMCglmm can run a multiple-response model, but we have to bind the column names of the response variable. This can be done manually, but it can get tedious.
area_traits = paste0("area", 1:7)
num_area_traits = length(area_traits)

value = paste("cbind(", paste(area_traits, collapse = ', '), ")", sep = '')

# Since we controled for fixed effect we can just use the overall mean as a reference
fixed_effects = "trait - 1"

# This is tha base formula for all the models
null_formula = paste(value, fixed_effects, sep = ' ~ ')

# We set up a function to run the null model, this keep the workspace clean
runNullMCMCModel <- function(null_formula, pl = TRUE, ...) {
  prior = list(R = list(V = diag(num_area_traits), n = 0.002),
               G = list(G1 = list(V = diag(num_area_traits) * 0.02, n = 0.001)))
  area_MCMC_null_model = MCMCglmm(as.formula(null_formula),
                                  random = ~us(trait):FAMILY,
                                  data = as.data.frame(area_data),
                                  rcov = ~us(trait):units,
                                  family = rep("gaussian", num_area_traits),
                                  prior = prior,
                                  pl = pl,
                                  verbose = TRUE, ...)
  return(area_MCMC_null_model)
}

area_MCMC_null_model = runNullMCMCModel(null_formula, nitt=150000, thin=100, burnin=50000)
write_rds(area_MCMC_null_model, "cached/area_MCMC_null_model.Rds")
area_MCMC_null_model = read_rds("cached/area_MCMC_null_model.Rds")

summary(area_MCMC_null_model)

Gs_mcmc = array(area_MCMC_null_model$VCV[,1:(num_area_traits*num_area_traits)], dim = c(1000, num_area_traits, num_area_traits))
G_mcmc = apply(array(area_MCMC_null_model$VCV[,1:(num_area_traits*num_area_traits)], dim = c(1000, num_area_traits, num_area_traits)), 2:3, median)

R_mcmc = apply(array(area_MCMC_null_model$VCV[,-c(1:(num_area_traits*num_area_traits))],
                     dim = c(1000, num_area_traits, num_area_traits)), 2:3, median)