# Look at convergence issues for fits

library(dplyr)
library(readr)
library(tidybayes)
library(brms)
library(bayesplot)

color_scheme_set('brewer-Dark2')

fd <- readRDS('~/temp/forestlight/diam_jcurve_fixef_brmfit.rds')
fm <- readRDS('~/temp/forestlight/mort_jcurve_fixef_brmfit.rds')

plot(fd)
plot(fm)
