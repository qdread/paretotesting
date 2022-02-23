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
	// Loglinear production
	real<lower=0> mu_beta0; // Intercept overall mean
	real<lower=0> mu_beta1; // Slope overall mean
	real<lower=0> sigma;
	vector[M] beta0_fg;
	vector[M] beta1_fg;
	real<lower=0> sigma_beta0;
	real<lower=0> sigma_beta1;
}

model {
	// Priors: Loglinear production
	mu_beta0 ~ lognormal(1, 1);
	mu_beta1 ~ lognormal(1, 1);
	
	sigma ~ exponential(0.1);
	sigma_beta0 ~ exponential(1);
	sigma_beta1 ~ exponential(1);
	
	beta0_fg ~ normal(mu_beta0, sigma_beta0);
	beta1_fg ~ normal(mu_beta1, sigma_beta1);
	
	// Likelihood: Loglinear production
	{
	  vector[N] mu;
	   
	  for (i in 1:N) {
		  mu[i] = log(beta0_fg[fg[i]]) + beta1_fg[fg[i]] * logx[i];
	  }
	  logy ~ normal(mu, sigma);
	}
}

/* 
generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
	
	for (i in 1:N) {
		log_lik[i] = normal_lpdf(logy[i] | log(beta0_fg[fg[i]]) + beta1_fg[fg[i]] * logx[i], sigma);
	}
}
 */