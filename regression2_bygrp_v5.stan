functions {
	real logistic_hinge(real x, real x0, real beta0, real beta1_low, real beta1_high, real delta) { 
		real xdiff = x - log(x0);
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
	real<lower=0> log_mu_x0;
	real<lower=0> mu_beta0;
	real<lower=0> mu_beta1_low;
	real<lower=0> mu_beta1_high;
	real<lower=0> delta;
	real<lower=0> sigma;
	
	vector[M] log_x0_fg;
	vector[M] log_beta0_fg;
	vector[M] log_beta1_low_fg;
	vector[M] log_beta1_high_fg;
	real<lower=0> sigma_x0;
	real<lower=0> sigma_beta0;
	real<lower=0> sigma_beta1_low;
	real<lower=0> sigma_beta1_high;
}

model {
	// Priors: Hinged production
	mu_beta0 ~ normal(0, 1);
	mu_beta1_low ~ normal(log(2), 1);
	mu_beta1_high ~ normal(log(2), 1);
	log_mu_x0 ~ normal(log(10), 1);
	delta ~ exponential(1);
	
	sigma ~ exponential(0.1);
	sigma_x0 ~ exponential(1);
	sigma_beta0 ~ exponential(1);
	sigma_beta1_low ~ exponential(1);
	sigma_beta1_high ~ exponential(1);
		
	log_x0_fg ~ normal(log_mu_x0, sigma_x0);
	log_beta0_fg ~ normal(mu_beta0, sigma_beta0);
	log_beta1_low_fg ~ normal(mu_beta1_low, sigma_beta1_low);
	log_beta1_high_fg ~ normal(mu_beta1_high, sigma_beta1_high);

	// Likelihood: hinged production
	{
	  vector[N] mu;
	   
	  for (i in 1:N) {
		  mu[i] = logistic_hinge(logx[i], exp(log_x0_fg[fg[i]]), exp(log_beta0_fg[fg[i]]), exp(log_beta1_low_fg[fg[i]]), exp(log_beta1_high_fg[fg[i]]), delta);
	  }
	  logy ~ normal(mu, sigma);
	}
}

/* 
generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
	
	for (i in 1:N) {
		log_lik[i] = normal_lpdf(logy[i] | logistic_hinge(logx[i], exp(log_x0_fg[fg[i]]), exp(log_beta0_fg[fg[i]]), exp(log_beta1_low_fg[fg[i]]), exp(log_beta1_high_fg[fg[i]]), delta), sigma);
	}
}
 */