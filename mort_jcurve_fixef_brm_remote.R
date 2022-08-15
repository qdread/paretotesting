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
    alpha ~ 1 + fg,
    beta ~ 1 + fg,
    gamma ~ 1 + fg,
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
