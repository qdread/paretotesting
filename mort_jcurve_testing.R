# Testing new mortality function

library(tidyverse)
library(cmdstanr)

mod <- cmdstan_model('mortreg_jcurve.stan')
