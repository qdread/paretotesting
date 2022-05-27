functions {
	// Definition of two part density function (new version created 12 Nov 2019)
	real logtwopart_lpdf(real x, real alpha_low, real alpha_high, real tau, real x_min) {
		real prob;
		real lprob;
		
		real C_con; // Continuity constant to make sure the two pieces meet
		real C_norm; // Normalization constant to make sure the pdf integrates to 1
		
		C_con = tau ^ (alpha_low - alpha_high);
		C_norm = ( (C_con / alpha_low) * (x_min ^ (-alpha_low) - tau ^ (-alpha_low)) + ( tau ^ (-alpha_high) ) / alpha_high ) ^ -1;
		
		if (x < tau) prob = C_con * C_norm * ( x ^ - (alpha_low + 1) );
		if (x >= tau) prob = C_norm * ( x ^ - (alpha_high + 1) );

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
	// Two part density
	real log_mu_alpha_low;
	vector[M] log_alpha_low_fg;			// Slope for each group, lower portion
	real<lower=0> sigma_alpha_low;		// SD of slopes, lower portion
	
	real log_mu_alpha_high;
	vector[M] log_alpha_high_fg;		// Slope of each group, upper portion
	real<lower=0> sigma_alpha_high;		// SD of slopes, upper portion
	
	real<lower=log(x_min), upper=log(x_max)> log_mu_tau;
	vector[M] log_tau_fg;				// Breakpoint for each group
	real<lower=0> sigma_tau;			// SD of breakpoints
}

model {
	// Prior: two part density
	log_mu_alpha_low ~ normal(1, 1);	
	log_mu_alpha_high ~ normal(1, 1);
	log_mu_tau ~ normal(log(10), 1);
	
	log_alpha_low_fg ~ normal(log_mu_alpha_low, sigma_alpha_low);
	log_alpha_high_fg ~ normal(log_mu_alpha_high, sigma_alpha_high);
	log_tau_fg ~ normal(log_mu_tau, sigma_tau);
	
	sigma_alpha_low ~ exponential(1);
	sigma_alpha_high ~ exponential(1);
	sigma_tau ~ exponential(1);
	
	// Likelihood: two part density
	for (i in 1:N) {
		x[i] ~ logtwopart(exp(log_alpha_low_fg[fg[i]]), exp(log_alpha_high_fg[fg[i]]), exp(log_tau_fg[fg[i]]), x_min);
	}
}

/*
generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
		
	for (i in 1:N) {
		log_lik[i] = logtwopart_lpdf(x[i] | exp(log_alpha_low_fg[fg[i]]), exp(log_alpha_high_fg[fg[i]]), exp(log_tau_fg[fg[i]]), x_min);
	}
}
*/