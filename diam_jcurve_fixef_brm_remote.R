# Testing new diameter model

library(dplyr)
library(readr)
#library(tidybayes)
library(brms)
#library(forestscaling)
#library(purrr)

options(mc.cores = 4, brms.backend = 'cmdstanr', brms.file_refit = 'on_change')

# Load data
load('~/GitHub/old_projects/forestscalingworkflow/data/rawdataobj1995.RData')

diam_data <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  select(fg, dbh_corr, diam_growth_rate) %>%
  mutate(fg = paste0('fg', fg))

# ### Visualize trends before writing model
# # Set number of bins       
# numbins <- 20
# 
# # Make a version of alltreedat without the unclassified trees
# alltreedat_classified <- map(alltreedat, ~ filter(., !is.na(fg)))
# 
# # Bin classified trees. (log binning of density)
# allyeardbh_classified <- map(alltreedat_classified[-1], ~ pull(., dbh_corr)) %>% unlist
# dbhbin_allclassified <- logbin(x = allyeardbh_classified, y = NULL, n = numbins)
# 
# diam_bins <- diam_data %>% 
#   group_by(fg) %>%
#   group_modify(~ cloudbin_across_years(dat_classes = .$dbh_corr, dat_values = .$diam_growth_rate, edges = dbhbin_allclassified, n_census = 1))
# 
# ggplot(diam_bins, aes(x = bin_midpoint, y = median, ymin = q25, ymax = q75)) +
#   geom_pointrange() + facet_wrap(~fg) + scale_x_log10() + scale_y_log10()

diam_jcurve_fixef_fit <- brm(
  bf(
    log(diam_growth_rate) ~ alpha + exp(beta) * log(dbh_corr) * exp(gamma * log(dbh_corr)),
    alpha ~ 0 + fg,
    beta ~ 0 + fg,
    gamma ~ 0 + fg,
    nl = TRUE
  ),
  data = diam_data, family = gaussian(link = 'identity'),
  prior = c(
    prior(normal(0, 2), nlpar = alpha),
    prior(normal(0, 2), nlpar = beta),
    prior(normal(0, 2), nlpar = gamma)
  ),
  chains = 4, iter = 3000, warmup = 2000, seed = 27704,
  file = '~/temp/forestlight/diam_jcurve_fixef_brmfit'
)

