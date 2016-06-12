# Unscaled data:

unscaled_area_plot = ggplot(n_area_data, aes(SEX, value)) +
  geom_boxplot() + geom_jitter(alpha = 0.3, height = 0, width = 0.05) +
  facet_wrap(~trait, scales = "free")
save_plot("output/figures/unscaled_area.png", unscaled_area_plot,
          base_height = 6, base_aspect_ratio = 1.8)

# Scaled data:

scaled_area_plot = ggplot(n_area_data_std, aes(trait, value)) +
  geom_violin() + geom_jitter(alpha = 0.3, height = 0, width = 0.1) +
  facet_wrap(~SEX)
save_plot("output/figures/scaled_area.png", scaled_area_plot,
          base_height = 6, base_aspect_ratio = 1.8)
