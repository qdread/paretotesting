# Testing new diameter model

library(dplyr)
library(readr)
library(tidybayes)
library(brms)

options(mc.cores = 4, brms.backend = 'cmdstanr', brms.file_refit = 'on_change')

# Load data
load('~/GitHub/old_projects/forestscalingworkflow/data/rawdataobj1995.RData')

diam_data <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  select(fg, dbh_corr, diam_growth_rate) %>%
  mutate(fg = paste0('fg', fg))

diam_jcurve_fixef_fit <- brm(
  bf(
    log(diam_growth_rate) ~ alpha + beta * log(dbh_corr) * exp(gamma * log(dbh_corr)),
    alpha ~ fg,
    beta ~ fg,
    gamma ~ fg,
    nl = TRUE
  ),
  data = diam_data, family = gaussian(link = 'identity'),
  prior = c(
    prior(normal(0, 2), nlpar = alpha),
    prior(normal(1, 2), nlpar = beta),
    prior(normal(0, 2), nlpar = gamma)
  ),
  chains = 4, iter = 5000, warmup = 4000, seed = 27704,
  file = '~/temp/forestlight/diam_jcurve_fixef_brmfit'
)

