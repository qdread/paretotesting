# Fit 1 and 2 segment mixed-effects random slope and intercept models for log linear regression to a subset of real data

library(tidyverse)
library(cmdstanr)

mod <- Sys.getenv('mod')

# Load the actual 1995 data
load('~/GitHub/forestscalingworkflow/data/rawdataobj1995.RData')

dat <- alltreedat[[3]] %>%
  filter(!is.na(fg))

production_data_dump <- with(dat, list(N = nrow(dat), M = 5, x = dbh_corr, y = production, x_min = 1, x_max = 286, fg = as.numeric(factor(fg))))

### ONE PART

if (mod == '1') {
  
  prod_mod <- cmdstan_model('~/GitHub/paretotesting/regression1_bygrp_v2.stan')
  
  prod_fit <- prod_mod$sample(
    data = production_data_dump,
    seed = 27605,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 2000,
    iter_sampling = 1000
  )
  
}

if (mod == '2') {
  
  prod_mod <- cmdstan_model('~/GitHub/paretotesting/regression2_bygrp_v5.stan')
  
  prod_fit <- prod_mod$sample(
    data = production_data_dump,
    seed = 27604,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 5000,
    iter_sampling = 1000,
    init = function(chain_id) list(delta = 0.1)
  )
  
}

prod_fit$save_object(paste0('/90daydata/shared/qdr/paretotest/prod_alldata_fit', mod, '.rds'))
summ <- prod_fit$summary()
saveRDS(summ, paste0('/90daydata/shared/qdr/paretotest/prod_alldata_fit', mod, '_summ.rds'))
