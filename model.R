library("rstan") 
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

model <- list(donation_size=100000,
                    discount_rate=0.04,
                    value_of_ln_consumption = 1.44,
                    value_of_under_5_death_averted = 117,
                    value_of_over_5_death_averted = 83
                    )

fit <- stan(file = 'model.stan', data = model)

print(fit)
plot(fit)
