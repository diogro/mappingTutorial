# First lets extract the model coefficients to a data.frame:
model = all_loci_list[[1]]
marker_effects = ldply(all_loci_list,
      function(model){
        model_summary = summary(model)

        # Additive effects
        ad = model_summary$solutions[(num_area_traits+1):(num_area_traits+num_area_traits), ]
        colnames(ad) = paste("ad", c("mean", "lower", "upper", "eff.samp", "pMCMC"), sep = "_")

        # Dominance effects
        dm = model_summary$solutions[(2*num_area_traits+1):(2*num_area_traits+num_area_traits), ]
        colnames(dm) = paste("dm", c("mean", "lower", "upper", "eff.samp", "pMCMC"), sep = "_")

        # P-values from the posterior distributions
        p_ad = colSums((model$Sol[,(num_area_traits+1):(num_area_traits+num_area_traits)]) > 0)/nrow(model$Sol)
        p_dm = colSums((model$Sol[,(2*num_area_traits+1):(2*num_area_traits+num_area_traits)]) > 0)/nrow(model$Sol)
        data.frame(trait = 1:num_area_traits, ad, dm, p_ad, p_dm)
      })
write_csv(marker_effects, "output/data/effects_singleLocus.csv")

# Per model DIC difference. A measure of how much better the fit with the marker is in relation to
# the null model. Higher values indicate more evidence in favor of an effect.

DIC_diff = area_MCMC_null_model$DIC - laply(all_loci_list, function(model) model$DIC)

# Now some plots:

marker_plot_data = marker_effects %>%
  select(chrom, marker, trait,
         ad_mean, ad_lower, ad_upper,
         dm_mean, dm_lower, dm_upper) %>%
  rename(additive = ad_mean, dominance = dm_mean) %>%
  gather(type, value, additive, dominance) %>%
  mutate(trait = as.factor(trait))

marker_plot <-
  ggplot(marker_plot_data, aes(trait, value, group = interaction(trait, type), color = trait)) +
  geom_hline(yintercept = 0) +
  geom_point() +
  geom_errorbar(data = filter(marker_plot_data, type == "additive"),
                aes(ymin = ad_lower, ymax = ad_upper), width = 0) +
  geom_errorbar(data = filter(marker_plot_data, type == "dominance"),
                aes(ymin = dm_lower, ymax = dm_upper), width = 0) +
  facet_grid(marker~type)
