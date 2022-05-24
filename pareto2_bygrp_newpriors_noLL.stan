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
	real<lower=x_min, upper=x_max> tau_mean;
	vector[M] tau_fg;
	real<lower=0> sigma_tau;
	
	real log_alpha_low_mean;
	vector[M] alpha_low_fg;			// Deviation of each group from mean intercept
	real<lower=0> sigma_alpha_low;	// Variation in intercepts
	
	real log_alpha_high_mean;
	vector[M] alpha_high_fg;		// Deviation of each group from mean intercept
	real<lower=0> sigma_alpha_high;	// Variation in intercepts
}

model {
	// Prior: two part density
	// No prior set for tau (uniform on its interval)
	log_alpha_low_mean ~ normal(1, 1);	
	log_alpha_high_mean ~ normal(1, 1);
	
	alpha_low_fg ~ normal(0, sigma_alpha_low);
	alpha_high_fg ~ normal(0, sigma_alpha_high);
	tau_fg ~ normal(0, sigma_tau);
	
	sigma_alpha_low ~ exponential(1);
	sigma_alpha_high ~ exponential(1);
	sigma_tau ~ exponential(1);
	
	// Likelihood: two part density
	for (i in 1:N) {
		x[i] ~ logtwopart(exp(log_alpha_low_mean + alpha_low_fg[fg[i]]), exp(log_alpha_high_mean + alpha_high_fg[fg[i]]), tau_mean + tau_fg[fg[i]], x_min);
	}
}
