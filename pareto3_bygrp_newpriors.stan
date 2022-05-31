functions {
	// Definition of three part density function
	real logthreepart_lpdf(real x, real alpha_low, real alpha_mid, real alpha_high, real tau_low, real tau_high, real x_min) {
		real prob;
		real lprob;
		
		real C_con_low; // Continuity constants to make sure the three pieces meet, one for low portion and one for high portion
		real C_con_high;
		real C_norm; // Normalization constant to make sure the pdf integrates to 1
		
		C_con_low = tau_low ^ (alpha_low - alpha_mid);
		C_con_high = tau_high ^ (alpha_high - alpha_mid);
		C_norm = ( (C_con_low / alpha_low) * (x_min ^ -alpha_low - tau_low ^ -alpha_low) + (1 / alpha_mid) * (tau_low ^ -alpha_mid - tau_high ^ -alpha_mid) + (C_con_high / alpha_high) * (tau_high ^ -alpha_high) ) ^ -1;
			
		if (x < tau_low) prob = C_con_low * C_norm * ( x ^ - (alpha_low + 1) );
		if (x >= tau_low && x <= tau_high) prob = C_norm * ( x ^ - (alpha_mid + 1) );
		if (x > tau_high) prob = C_con_high * C_norm * ( x ^ - (alpha_high + 1) );

		lprob = log(prob);

		return lprob;
	}
}

data {
	int<lower=0> N;
	int<lower=0> M;
	vector<lower=0>[N] x;
	vector<lower=0>[N] y;
  real<lower=0> x_min;
  real<lower=0> x_max;
	int<lower=1,upper=M> fg[N];	// Mapping to groups 1-M
}

parameters {
	// Three part density
	real log_mu_alpha_low;
	vector[M] log_alpha_low_fg;			// Slope for each group, lower portion
	real<lower=0> sigma_alpha_low;		// SD of slopes, lower portion
	
	real log_mu_alpha_mid;
	vector[M] log_alpha_mid_fg;			// Slope for each group, middle portion
	real<lower=0> sigma_alpha_mid;		// SD of slopes, middle portion
	
	real log_mu_alpha_high;
	vector[M] log_alpha_high_fg;		// Slope for each group, upper portion
	real<lower=0> sigma_alpha_high;		// SD of slopes, upper portion
	
	real<lower=log(x_min), upper=log(x_max)> log_mu_tau_low;
	vector[M] log_tau_low_fg;			// Lower breakpoint for each group
	real<lower=0> sigma_tau_low;		// SD of lower breakpoint
	
	real<lower=log_mu_tau_low, upper=log(x_max)> log_mu_tau_high;
	vector[M] log_tau_high_fg;			// Upper breakpoint for each group
	real<lower=0> sigma_tau_high;		// SD of upper breakpoints
}

model {
	// Prior: three part density
	log_mu_alpha_low ~ normal(1, 1);	
	log_mu_alpha_mid ~ normal(1, 1);	
	log_mu_alpha_high ~ normal(1, 1);
	log_mu_tau_low ~ normal(log(5), 1);
	log_mu_tau_high ~ normal(log(25), 1);
	
	log_alpha_low_fg ~ normal(log_mu_alpha_low, sigma_alpha_low);
	log_alpha_mid_fg ~ normal(log_mu_alpha_mid, sigma_alpha_mid);
	log_alpha_high_fg ~ normal(log_mu_alpha_high, sigma_alpha_high);
	log_tau_low_fg ~ normal(log_mu_tau_low, sigma_tau_low);
	log_tau_high_fg ~ normal(log_mu_tau_high, sigma_tau_high);
	
	sigma_alpha_low ~ gamma(1.5, 4);
	sigma_alpha_mid ~ gamma(1.5, 4);
	sigma_alpha_high ~ gamma(1.5, 4);
	sigma_tau_low ~ gamma(1.5, 4);
	sigma_tau_high ~ gamma(1.5, 4);
	
	// Likelihood: three part density
	for (i in 1:N) {
		x[i] ~ logthreepart(exp(log_alpha_low_fg[fg[i]]), exp(log_alpha_mid_fg[fg[i]]), exp(log_alpha_high_fg[fg[i]]), exp(log_tau_low_fg[fg[i]]), exp(log_tau_high_fg[fg[i]]), x_min);
	}
}

/*
generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
		
	for (i in 1:N) {
		log_lik[i] = logthreepart_lpdf(x[i] | exp(log_alpha_low_fg[fg[i]]), exp(log_alpha_mid_fg[fg[i]]), exp(log_alpha_high_fg[fg[i]]), exp(log_tau_low_fg[fg[i]]), exp(log_tau_high_fg[fg[i]]), x_min);
	}
}
*/