diam_data <- alltreedat[[3]] %>%
  filter(!is.na(fg), !recruit) %>%
  select(fg, dbh_corr, diam_growth_rate) %>%
  mutate(fg = paste0('fg', fg))


qprobs <- c(0.025, 0.25, 0.5, 0.75, 0.975)
diam_bins <- diam_data %>% 
  mutate(dbh_bin = cut(dbh_corr, breaks = bin_edges, include.lowest = TRUE)) %>%
  group_by(fg, dbh_bin) %>%
  summarize(p = qprobs, q = quantile(diam_growth_rate, probs = qprobs), n = n()) %>%
  pivot_wider(names_from = p, values_from = q) %>%
  setNames(c('fg', 'dbh_bin', 'n', 'q025', 'q25', 'median', 'q75', 'q975')) %>%
  mutate(bin_midpoint = dbhbin_allclassified$bin_midpoint[as.numeric(dbh_bin)])
