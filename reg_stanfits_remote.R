# Test whether 1 and 2 segment mixed-effects random slope and intercept models for log linear regression will compile
# If so, try to fit the model to fake data.

library(tidyverse)
library(cmdstanr)

prod_mod1 <- cmdstan_model('~/GitHub/NEON/paretotesting/regression1_bygrp_v2.stan')
prod_mod2 <- cmdstan_model('~/GitHub/NEON/paretotesting/regression2_bygrp_v4.stan')
# They compile!!!

# load the data to test it on real data
load('~/GitHub/forestscalingworkflow/data/rawdataobj1995.RData')

# Thin down the data to a manageable amount for testing.
dat <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  group_by(fg) %>%
  sample_n(5000)

production_data_dump <- with(dat, list(N = nrow(dat), M = 5, x = dbh_corr, y = production, x_min = 1, x_max = 286, fg = as.numeric(factor(fg))))

### ONE PART

prod_fit1 <- prod_mod1$sample(
  data = production_data_dump,
  seed = 524,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 1000
)

prod_fit1$save_object('/90daydata/shared/qdr/paretotest/prod_fit1.rds')

summ <- prod_fit1$summary()

saveRDS(summ, '/90daydata/shared/qdr/paretotest/prod_fit1_summ.rds')

### TWO PART

prod_fit2 <- prod_mod2$sample(
  data = production_data_dump,
  seed = 5242,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 1000,
  init = function(chain_id) list(delta = 1)
)

prod_fit2$save_object('/90daydata/shared/qdr/paretotest/prod_fit2.rds')

summ2 <- prod_fit2$summary()

saveRDS(summ2, '/90daydata/shared/qdr/paretotest/prod_fit2_summ.rds')