install_load("doParallel")
registerDoParallel(cores = 3)

num_loci = 5
makeMarkerList = function(pos) paste(paste('trait:', c('A', 'D'), pos[2], sep = ''),
                                     collapse = ' + ')
markerMatrix = ldply(1, function(x) data.frame(chrom = x, locus = 1:num_loci))
markerList = alply(markerMatrix, 1, makeMarkerList)

runSingleLocusMCMCModel <- function(marker_term, null_formula, start = NULL, ...){
  genotype.formula = paste(null_formula, marker_term, sep = ' + ')
  prior = list(R = list(V = diag(num_area_traits), n = 0.002),
               G = list(G1 = list(V = diag(num_area_traits) * 0.02, n = num_area_traits+1)))
  area_MCMC_singleLocus = tryCatch({
    model_file = paste0("cached/area_MCMC_single_locus_model", marker_term,".Rds")
    read_rds(model_file)
  },
  error = function(cond) {
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

all_loci_list = llply(markerList, runSingleLocusMCMCModel,
                      null_formula, start, nitt=3100, thin=10, burnin=3000, .parallel = TRUE)
