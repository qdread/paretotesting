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
	//vector<lower=0>[N] y;
    real<lower=0> x_min;
    real<lower=0> x_max;
	int<lower=1,upper=M> fg[N];	// Mapping to groups 1-M
}

parameters {
	// Three part density
	real<lower=x_min, upper=x_max> tau_low_mean;
	vector[M] tau_low_fg;
	real<lower=0> sigma_tau_low;
	
	real<lower=x_min, upper=x_max> tau_high_mean;
	vector[M] tau_high_fg;
	real<lower=0> sigma_tau_high;
	
	real log_alpha_low_mean;
	vector[M] alpha_low_fg;			// Deviation of each group from mean intercept
	real<lower=0> sigma_alpha_low;	// Variation in intercepts
	
	real log_alpha_mid_mean;
	vector[M] alpha_mid_fg;			// Deviation of each group from mean intercept
	real<lower=0> sigma_alpha_mid;	// Variation in intercepts
	
	real log_alpha_high_mean;
	vector[M] alpha_high_fg;		// Deviation of each group from mean intercept
	real<lower=0> sigma_alpha_high;	// Variation in intercepts
}

model {
	// Prior: three part density
	// No prior set for tau (uniform on its interval)
	log_alpha_low_mean ~ normal(1, 1);	
	log_alpha_mid_mean ~ normal(1, 1);	
	log_alpha_high_mean ~ normal(1, 1);
	
	alpha_low_fg ~ normal(0, sigma_alpha_low);
	alpha_mid_fg ~ normal(0, sigma_alpha_mid);
	alpha_high_fg ~ normal(0, sigma_alpha_high);
	tau_low_fg ~ normal(0, sigma_tau_low);
	tau_high_fg ~ normal(0, sigma_tau_high);
	
	sigma_alpha_low ~ exponential(1);
	sigma_alpha_mid ~ exponential(1);
	sigma_alpha_high ~ exponential(1);
	sigma_tau_low ~ exponential(1);
	sigma_tau_high ~ exponential(1);
	
	// Likelihood: three part density
	for (i in 1:N) {
		x[i] ~ logthreepart(exp(log_alpha_low_mean + alpha_low_fg[fg[i]]), exp(log_alpha_mid_mean + alpha_mid_fg[fg[i]]), exp(log_alpha_high_mean + alpha_high_fg[fg[i]]), tau_low_mean + tau_low_fg[fg[i]], tau_high_mean + tau_high_fg[fg[i]], x_min);
	}
}

generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
		
	for (i in 1:N) {
		log_lik[i] = logthreepart_lpdf(x[i] | exp(log_alpha_low_mean + alpha_low_fg[fg[i]]), exp(log_alpha_mid_mean + alpha_mid_fg[fg[i]]), exp(log_alpha_high_mean + alpha_high_fg[fg[i]]), tau_low_mean + tau_low_fg[fg[i]], tau_high_mean + tau_high_fg[fg[i]], x_min);
	}
}
