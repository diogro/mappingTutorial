# We are going to fit just 5 markers, but the program will work for more
num_loci = 5

# For the split-apply tecnique we are going to use, creating the aditional marker terms for the
# fixed effect formulas in advance is a major advantage.
# For each marker we need a term of the kind: trait:A* + trait:D*, where * stands for the marker number
# The trait: allows us to fit different additive effects for each trait.
makeMarkerList = function(pos) paste(paste('trait:', c('A', 'D'), pos[2], sep = ''),
                                     collapse = ' + ')
markerMatrix = ldply(1, function(x) data.frame(chrom = x, marker = 1:num_loci))

# This line will create a list of the required marker terms.
markerList = alply(markerMatrix, 1, makeMarkerList)

# This function is almost identical to the null model function, but it includes the creation of the
# formula with the marker term.
runSingleLocusMCMCModel <- function(marker_term, null_formula, start = NULL, ...){
  genotype.formula = paste(null_formula, marker_term, sep = ' + ') # creating the marker term.

  # all the rest is the same as in the null model
  prior = list(R = list(V = diag(num_area_traits), n = 0.002),
               G = list(G1 = list(V = diag(num_area_traits) * 0.02, n = num_area_traits+1)))
  area_MCMC_singleLocus <-
    tryCatch({ # first look for a cached model...
      model_file = paste0("cached/area_MCMC_single_locus_model", marker_term,".Rds")
      read_rds(model_file)
    },
    error = function(cond) {           # if there is no cache, run the model.
      area_singleMarker_model <-
        MCMCglmm(as.formula(genotype.formula),
                 random = ~us(trait):FAMILY,
                 data = as.data.frame(area_data),
                 rcov = ~us(trait):units,
                 family = rep("gaussian", num_area_traits),
                 start = start,
                 prior = prior,
                 verbose = FALSE,
                 ...)
      write_rds(area_singleMarker_model, model_file)
    })
  return(area_MCMC_singleLocus)
}

# This is the split-apply tecnique using plyr. It allows us to run the models in parallel trivially.
all_loci_list = llply(markerList, runSingleLocusMCMCModel,
                      null_formula, start, nitt=10300, thin=10, burnin=300, .parallel = TRUE)