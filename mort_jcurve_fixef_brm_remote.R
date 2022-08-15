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
    died ~ exp(alpha) + -exp(beta) * log(dbh) * exp(gamma * log(dbh)),
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
# dbh_pred <- exp(seq(log(1), log(285), length.out = 50))
# pred_dat <- expand.grid(dbh = dbh_pred, fg = paste0('fg', 1:5))
# 
# # Get epred values
# jcurve_pred <- pred_dat %>%
#   add_epred_draws(mort_jcurve_fixef_fit)
# 
# ### Quick diag. plot
# ggplot(mort_bins %>% filter(variable == "dbh", !fg %in% "unclassified", (lived+died) > 20), aes(x=bin_midpoint, y=mortality)) +
#   stat_lineribbon(aes(y = .epred, x = dbh), data = jcurve_pred) +
#   geom_point() +
#   facet_wrap(~ fg, scales = 'free_x') + scale_x_log10() + scale_y_log10() +
#   scale_fill_brewer(palette = 'Blues') + theme_bw()
