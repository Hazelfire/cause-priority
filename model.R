library("rstan") 
library(tidyverse)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

model <- list(donation_size=100000,
                    discount_rate=0.04,
                    value_of_ln_consumption = 1.44,
                    value_of_under_5_death_averted = 117,
                    value_of_over_5_death_averted = 83
                    )
beta_model <- list(data_size = 0,
                   y = c(),
                   alpha_prior_mu = 7,
                   beta_prior_mu = 2
                   )

#fit <- stan(file = 'models/beta.stan', data = beta_model)

#print(fit)
#plot(fit)

prior_alpha = rexp(1000,rate = 1/beta_model$alpha_prior_mu)
prior_beta = rexp(1000,rate = 1/beta_model$beta_prior_mu)
prior_predictive = rbeta(1, alpha=prior_alpha, beta=prior_beta)
ggplot(prior_predictive) + geom_histogram()

