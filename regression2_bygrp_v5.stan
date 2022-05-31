functions {
	real logistic_hinge(real x, real tau, real beta0, real beta1_low, real beta1_high, real delta) { 
		real xdiff = x - log(tau);
		return log(beta0) + beta1_low * xdiff + (beta1_high - beta1_low) * delta * log1p_exp(xdiff / delta);
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

transformed data {
	vector[N] logx;
	vector[N] logy;
	logx = log(x);
	logy = log(y);
}

parameters {
	// Hinged production. All parameters will vary by functional group except delta (smoothing parameter).
	real log_mu_tau;
	real log_mu_beta0;
	real log_mu_beta1_low;
	real log_mu_beta1_high;
	real<lower=0> delta;
	real<lower=0> sigma;
	
	vector[M] log_tau_fg;
	vector[M] log_beta0_fg;
	vector[M] log_beta1_low_fg;
	vector[M] log_beta1_high_fg;
	real<lower=0> sigma_tau;
	real<lower=0> sigma_beta0;
	real<lower=0> sigma_beta1_low;
	real<lower=0> sigma_beta1_high;
}

model {
	// Priors: Hinged production
	log_mu_beta0 ~ normal(0, 1);
	log_mu_beta1_low ~ normal(1, 1);
	log_mu_beta1_high ~ normal(1, 1);
	log_mu_tau ~ normal(log(10), 1);
	delta ~ gamma(1.1, 1);
	
	sigma ~ gamma(5, 1);
	sigma_tau ~ gamma(1.5, 4);
	sigma_beta0 ~ gamma(1.5, 4);
	sigma_beta1_low ~ gamma(1.5, 4);
	sigma_beta1_high ~ gamma(1.5, 4);
		
	log_tau_fg ~ normal(log_mu_tau, sigma_tau);
	log_beta0_fg ~ normal(log_mu_beta0, sigma_beta0);
	log_beta1_low_fg ~ normal(log_mu_beta1_low, sigma_beta1_low);
	log_beta1_high_fg ~ normal(log_mu_beta1_high, sigma_beta1_high);

	// Likelihood: hinged production
	{
	  vector[N] mu;
	   
	  for (i in 1:N) {
		  mu[i] = logistic_hinge(logx[i], exp(log_tau_fg[fg[i]]), exp(log_beta0_fg[fg[i]]), exp(log_beta1_low_fg[fg[i]]), exp(log_beta1_high_fg[fg[i]]), delta);
	  }
	  logy ~ normal(mu, sigma);
	}
}

/* 
generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
	
	for (i in 1:N) {
		log_lik[i] = normal_lpdf(logy[i] | logistic_hinge(logx[i], exp(log_tau_fg[fg[i]]), exp(log_beta0_fg[fg[i]]), exp(log_beta1_low_fg[fg[i]]), exp(log_beta1_high_fg[fg[i]]), delta), sigma);
	}
}
 */