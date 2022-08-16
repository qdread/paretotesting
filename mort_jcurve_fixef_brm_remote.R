# Mortality J-curve function on BRMS with fixed effects for functional group, to be run remotely
# QDR 2022-08-15

library(dplyr)
library(readr)
library(brms)

options(mc.cores = 4, brms.backend = 'cmdstanr', brms.file_refit = 'on_change')

# Read mortality data and convert to Stan data list
mort <- read_csv('~/GitHub/old_projects/forestscalingworkflow/data/data_forplotting/obs_mortalityindividuals.csv')

mort_data <- mort %>%
  filter(!fg %in% 'unclassified') %>%
  mutate(died = alive == 0) %>%
  select(fg, died, dbh)

mort_jcurve_fixef_fit <- brm(
  bf(
    died ~ alpha + -exp(beta) * log(dbh) * exp(gamma * log(dbh)),
    alpha ~ 0 + fg,
    beta ~ 0 + fg,
    gamma ~ 0 + fg,
    nl = TRUE
  ),
  data = mort_data, family = bernoulli(link = 'logit'),
  prior = c(
    prior(normal(0, 2), nlpar = alpha),
    prior(normal(0, 2), nlpar = beta),
    prior(normal(0, 2), nlpar = gamma)
  ),
  chains = 4, iter = 3000, warmup = 2000, seed = 27701,
  file = '~/temp/forestlight/mort_jcurve_fixef_brmfit'
)


# Postprocessing and plotting locally -------------------------------------

# library(tidybayes)
# library(ggplot2)
# 
# # Read pre-created mortality bins for plotting to compare to fitted values
# mort_bins <- read_csv('~/GitHub/old_projects/forestscalingworkflow/data/data_forplotting/obs_mortalitybins.csv')
# 
# # Prediction grid: dbh x fg
# # Limit ranges to the observed data points
# mort_max <- mort_bins %>% 
#   filter((lived + died) > 20, variable %in% 'dbh', fg %in% paste0('fg', 1:5)) %>%
#   group_by(fg) %>%
#   filter(bin_midpoint == max(bin_midpoint))
# 
# pred_dat <- mort_max %>%
#   group_by(fg) %>%
#   group_modify(~ data.frame(dbh = exp(seq(log(1), log(.$bin_midpoint), length.out = 50))))
# 
# # Get epred values
# jcurve_pred <- pred_dat %>%
#   add_epred_draws(mort_jcurve_fixef_fit)
# 
# ### Quick diag. plot
# ggplot(mort_bins %>% filter(variable == "dbh", fg %in% paste0('fg', 1:5), (lived+died) > 20), aes(x=bin_midpoint, y=mortality)) +
#   stat_lineribbon(aes(y = .epred, x = dbh), data = jcurve_pred) +
#   geom_point(aes(size = lived+died)) +
#   facet_wrap(~ fg) + scale_x_log10() + scale_y_log10() + scale_size(trans = 'log10', range = c(0.5, 4)) +
#   scale_fill_brewer(palette = 'Blues') + theme_bw()
