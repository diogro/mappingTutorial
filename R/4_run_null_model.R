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

  # Priors can get confusing. For normal data it's just a matter of setting the covariance matrix
  # for the random effects (1 for each random term) and the residual.
  # In our case these are inverse-wishart with diagonal scale matrices of the same dimension
  # as the number of traits.
  prior = list(R = list(V = diag(num_area_traits), n = 0.002),
               G = list(G1 = list(V = diag(num_area_traits) * 0.02, n = 0.001)))

  # This is the main model call
  area_MCMC_null_model = MCMCglmm(as.formula(null_formula),   # - fixed effects
                                  random = ~us(trait):FAMILY, # - random effects covariance matrix
                                  data = as.data.frame(area_data_std),
                                  rcov = ~us(trait):units,    # - Residual covariance matrix
                                  family = rep("gaussian",    # - multivarite gaussian response
                                               num_area_traits),
                                  prior = prior,              # - the prior on the covariance terms
                                  pl = pl,                    # - this allows us to set a starting
                                                              #   point for the next models
                                  verbose = TRUE, ...)
  return(area_MCMC_null_model)
}

# This will look for a saved run in the cached folder, if it isn't there
# it will run the model and save it
area_MCMC_null_model = tryCatch({
    read_rds("cached/area_MCMC_null_model.Rds")
  },
  error = function(cond) {
    message(cond)
    message("\nCould not find cached model, running null model")
    area_MCMC_null_model = runNullMCMCModel(null_formula, nitt=15000, thin=10, burnin=5000)
    write_rds(area_MCMC_null_model, "cached/area_MCMC_null_model.Rds")
    return(area_MCMC_null_model)
  })

summary(area_MCMC_null_model)

# The covariance structure is in the $VCV slot in the model, while the fixed effects are in $Sol
n_mcmc = dim(area_MCMC_null_model$Sol)[1]

# We can estimate the covariance matrices as the posterior medians, using some indexing of the
# VCV object:
G_mcmc = apply(array(area_MCMC_null_model$VCV[,1:(num_area_traits*num_area_traits)],
                     dim = c(n_mcmc, num_area_traits, num_area_traits)), 2:3, median)
R_mcmc = apply(array(area_MCMC_null_model$VCV[,-c(1:(num_area_traits*num_area_traits))],
                     dim = c(n_mcmc, num_area_traits, num_area_traits)), 2:3, median)

# One simple check of the model fit is to see if the phenotypic matrix is
# the sum of the G and the residual
P = area_data_std %>% select(area1:area7) %>% cov
PvsGR_plot = data.frame(  P =                 P[lower.tri(P, T)],
                        G.R = (G_mcmc + R_mcmc)[lower.tri(P, T)]) %>%
  ggplot(aes(P, G.R)) + geom_point() + geom_abline()
save_plot("output/figures/PvsGR.png", PvsGR_plot, base_height = 6, base_width = 1.8)

# Now we use this to set up a starting point of the next models. Much faster!
start <- list(R = list(V = R_mcmc),
              G = list(G1 = G_mcmc),
              liab = matrix(area_MCMC_null_model$Liab[1,],
                            ncol = num_area_traits))