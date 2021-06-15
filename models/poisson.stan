/* Poisson Distribution with exponential prior */
data {
  int data_size;
  real[data_size] y;
  real mu_prior_mu;
}

parameters {
  real mu;
}

model {
  mu ~ exponential(mu_prior_mu);
  y ~ poisson(mu);
}
