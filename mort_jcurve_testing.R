# Testing new mortality function

library(dplyr)
library(readr)
library(tidybayes)
library(cmdstanr)

j_mod <- cmdstan_model('mortreg_jcurve.stan')
lin_mod <- cmdstan_model('~/GitHub/old_projects/forestscalingworkflow/model_scripts/mortreg_fg_v3.stan')

# Read mortality data and convert to Stan data list
mort <- read_csv('~/GitHub/old_projects/forestscalingworkflow/data/data_forplotting/obs_mortalityindividuals.csv')

# Read pre-created mortality bins for plotting to compare to fitted values
mort_bins <- read_csv('~/GitHub/old_projects/forestscalingworkflow/data/data_forplotting/obs_mortalitybins.csv')

mort_data <- mort %>%
  filter(!fg %in% 'unclassified') %>%
  mutate(died = alive == 0) %>%
  select(fg, died, dbh)

mort_data_dump <- with(mort_data, list(N = nrow(mort_data), M = 5, x = dbh, y = as.numeric(died), fg = as.numeric(factor(fg))))

# Sample model
jcurve_fit <- j_mod$sample(
  data = mort_data_dump,
  seed = 27701,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 4000,
  iter_sampling = 1000
)

if (!file.exists('~/temp/forestlight/mort_lin_fit.rds')) {
lin_fit <- lin_mod$sample(
  data = mort_data_dump,
  seed = 27705,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 1000
)
lin_fit$save_object('~/temp/forestlight/mort_lin_fit.rds')
}

# Save object
jcurve_fit$save_object('~/temp/forestlight/mort_jcurve_fit.rds')


# Check model summary
jcurve_summ <- jcurve_fit$summary() # This did not really converge but it is probably OK for now

# Extract fitted values and plot versus observed values
# -----------------------------------------------------

# Get parameters
jcurve_pars <- gather_draws(jcurve_fit, alpha_fg[fg], beta_fg[fg], gamma_fg[fg]) %>%
  pivot_wider(names_from = .variable, values_from = .value)

# Values to predict at
dbh_pred <- exp(seq(log(1), log(285), length.out = 50))
pred_dat <- expand.grid(dbh = dbh_pred, fg = 1:5)

jcurve_fn <- function(x, alpha, beta, gamma) plogis( alpha + beta * log10(x) * exp(gamma * log10(x)) )

jcurve_fitted_raw <- full_join(jcurve_pars, pred_dat) %>%
  mutate(y = jcurve_fn(x = dbh, alpha = alpha_fg, beta = beta_fg, gamma = gamma_fg))

qprobs <- c(0.5, 0.025, 0.975)

jcurve_fitted_quant <- jcurve_fitted_raw %>%
  group_by(fg, dbh) %>%
  summarize(p = qprobs, q = quantile(y, probs = qprobs)) %>%
  pivot_wider(names_from = p, values_from = q, names_prefix = 'q') %>%
  mutate(fg = paste0('fg', fg))

# Calculate binned mortality by dbh (use existing dbh bins that we always use)


#### PLOT

library(ggplot2)

theme_plant <- theme(panel.grid = element_blank(), #for Total Production
                     aspect.ratio = .75,
                     axis.text = element_text(size = 15, color = "black"), 
                     axis.ticks.length=unit(0.2,"cm"),
                     axis.title = element_text(size = 15),
                     axis.title.y = element_text(margin = margin(r = 10)),
                     axis.title.x = element_text(margin = margin(t = 10)),
                     axis.title.x.top = element_text(margin = margin(b = 5)),
                     plot.title = element_text(size = 15, face = "plain", hjust = 10),
                     panel.border = element_rect(color = "black", fill=NA,  size=1),
                     panel.background = element_rect(fill = "transparent",colour = NA),
                     plot.background = element_rect(fill = "transparent",colour = NA),
                     legend.position = "none",
                     rect = element_rect(fill = "transparent"),
                     text = element_text(family = 'Helvetica')) 

fg_labels <- c('Fast','LL Pioneer', 'Slow', 'SL Breeder', 'Medium')
guild_fills_nb <- c("#BFE046", "#267038", "#27408b", "#87Cefa", "gray")

theme_set(theme_plant)

mort_bins_toplot <- mort_bins %>% 
  filter(variable %in% 'dbh' & fg %in% paste0('fg', 1:5) & (lived+died) >= 20)

obs_range_mort <- mort_bins_toplot %>%
  group_by(fg) %>%
  summarize(min_obs = min(bin_midpoint), max_obs = max(bin_midpoint))

jcurve_fitted_toplot <- jcurve_fitted_quant %>%
  left_join(obs_range_mort) %>%
  filter(dbh >= min_obs & dbh <= max_obs)

ggplot(jcurve_fitted_toplot, aes(x = dbh, y = q0.5, color = fg, fill = fg)) +
  geom_point(data = mort_bins_toplot, aes(x = bin_midpoint, y = mortality)) +
  geom_ribbon(aes(ymin = q0.025, ymax = q0.975), alpha = 0.25, color = NA) +
  geom_line(size = 0.8) +
  scale_x_log10(name = 'Diameter (cm)') +
  scale_y_continuous(breaks = c(0.03, 0.1, 0.3), labels = c(0.03, 0.1, 0.3), limits = c(0.02, .5),
                     name = expression(paste("Mortality (5 yr"^-1,")")), trans = 'logit') +
  scale_color_manual(values = guild_fills_nb) +
  scale_fill_manual(values = guild_fills_nb) 
