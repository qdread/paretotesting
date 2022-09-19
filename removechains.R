
remove_chains = function(brm_fit, chains_to_drop) {
  # brm_fit is the output of brms::brm
  
  sim = brm_fit$fit@sim  # Handy shortcut
  sim$samples <- sim$samples[-chains_to_drop]
  
  # Update the meta-info
  sim$chains = sim$chains - length(chains_to_drop)
  sim$warmup2 = sim$warmup2[-chains_to_drop]
  
  # Add the modified sim back to x
  brm_fit$fit@sim = sim
  brm_fit
}

diam_jcurve_fixef_fit <- remove_chains(diam_jcurve_fixef_fit, 1:2)
