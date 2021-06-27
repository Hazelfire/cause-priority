/* Normal Distribution with lognormal and exponential priors */
data {
  int data_size;
  real[data_size] y;
  real mu_prior_mu;
  real mu_prior_sigma;
  real sigma_prior_mu;
}

parameters {
  real mu;
  real sigma;
}

model {
  mu ~ lognormal(mu_prior_mu, mu_prior_sigma);
  sigma ~ exponential(sigma_prior_mean);
  y ~ normal(rep_array(mu, data_size), sigma);
}
