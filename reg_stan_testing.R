# Test whether 1 and 2 segment mixed-effects random slope and intercept models for log linear regression will compile
# If so, try to fit the model to fake data.

library(tidyverse)
library(cmdstanr)

reg1_mod <- cmdstan_model('~/R/regression1_bygrp.stan')
reg2_mod <- cmdstan_model('~/R/regression2_bygrp.stan')
# They compile!!!

# load the data to test it on real data
load('~/GitHub/old_projects/forestscalingworkflow/data/rawdataobj1995.RData')

# Thin down the data to a manageable amount for testing.
dat <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  group_by(fg) %>%
  sample_n(3000)

production_data_dump <- with(dat, list(N = nrow(dat), M = 5, x = dbh_corr, y = production, x_min = 1, x_max = 286, fg = as.numeric(factor(fg))))

prod1_fit <- reg1_mod$sample(
  data = production_data_dump,
  seed = 517,
  chains = 3,
  parallel_chains = 3,
  iter_warmup = 1000,
  iter_sampling = 1000,
 # adapt_delta = 0.9,
 # max_treedepth = 20
)
