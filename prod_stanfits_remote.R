# Fit 1 and 2 segment mixed-effects random slope and intercept models for log linear regression to a subset of real data

library(tidyverse)
library(cmdstanr)

mod <- Sys.getenv('mod')

# Load the actual 1995 data
load('~/GitHub/forestscalingworkflow/data/rawdataobj1995.RData')

# Thin down the data to a manageable amount for testing.
set.seed(52522)
dat <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  group_by(fg) %>%
  sample_n(5000)

production_data_dump <- with(dat, list(N = nrow(dat), M = 5, x = dbh_corr, y = production, x_min = 1, x_max = 286, fg = as.numeric(factor(fg))))

### ONE PART

if (mod == '1') {
  
  prod_mod <- cmdstan_model('~/GitHub/paretotesting/regression1_bygrp_v2.stan')
  
  prod_fit <- prod_mod$sample(
    data = production_data_dump,
    seed = 524,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 2000,
    iter_sampling = 1000
  )
  
}

if (mod == '2') {
  
  prod_mod <- cmdstan_model('~/GitHub/paretotesting/regression2_bygrp_v4.stan')
  
  prod_fit <- prod_mod$sample(
    data = production_data_dump,
    seed = 5242,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 4000,
    iter_sampling = 1000,
    init = function(chain_id) list(delta = 1)
  )
  
}

prod_fit$save_object(paste0('/90daydata/shared/qdr/paretotest/prod_fit', mod, '.rds'))
summ <- prod_fit$summary()
saveRDS(summ, paste0('/90daydata/shared/qdr/paretotest/prod_fit', mod, '_summ.rds'))
