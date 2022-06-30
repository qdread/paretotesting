# Testing new diameter model

library(dplyr)
library(readr)
library(tidybayes)
library(brms)

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
    prior(normal(0, 5), nlpar = alpha),
    prior(normal(0, 5), nlpar = beta),
    prior(normal(0, 5), nlpar = gamma)
  ),
  chains = 4, iter = 2000, warmup = 1000, seed = 27703,
  file = '~/temp/forestlight/diam_jcurve_fixef_brmfit'
)

