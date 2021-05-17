functions{
  // Future Value
  real pv(real future_value, real rate_of_return, real number_of_periods) {
    return future_value / pow(1 + rate_of_return, number_of_periods);
  }
}
data {
  real donation_size;
  real discount_rate;
  real value_of_ln_consumption;
  real value_of_under_5_death_averted;
  real value_of_over_5_death_averted;
}
parameters {
  // Give Directly
  real<lower=0,upper=1> givedirectly_proportion;
  real<lower=0> givedirectly_size_of_transfer;
  real<lower=0> givedirectly_household_size;
  real<lower=0,upper=1> givedirectly_transfers_invested;
  real<lower=0> givedirectly_consumption_per_capita;
  real<lower=0,upper=1> givedirectly_roi;
  real<lower=0> givedirectly_investment_duration;
  real<lower=0,upper=1> givedirectly_percent_of_investment_returned;
  real<lower=0,upper=1> givedirectly_discount_negative_spoiler;

  // AMF
  vector<lower=0,upper=1> proportion_each_location;
  vector<lower=0,upper=1> amf_cost_covered;
  vector<lower=0,upper=1> amf_cost_covered_philanthropic;
  vector<lower=0> amf_cost_llin;
  real<lower=0> amf_covered_by_net;
  vector<lower=0,upper=1> amf_population_under_5;
  vector<lower=0,upper=1> amf_population_between_5_9;
  vector<lower=0,upper=1> amf_population_between_10_14;
  vector<lower=0> amf_coverage_years_llin;
  real<lower=0> amf_relative_risk_of_death_averted_per_under_5;
  vector<lower=0> amf_mortality_under_5_before_nets;
  vector<lower=0> amf_mortality_under_5_after_nets;
  real<lower=0> amf_portion_of_mortality_attribute_to_nets;
  real<lower=0,upper=1> amf_percent_own_nets_without_amf;
  real<lower=0,upper=1> amf_percent_own_nets_with_amf;
  real<lower=0,upper=1> amf_net_use_adjustment;
  real<lower=0,upper=1> amf_internal_validity;
  real<lower=0,upper=1> amf_external_validity;
  vector<lower=0> amf_mortality_attributed_vs_context;
  vector<lower=0> amf_efficacy_reduction_due_to_resistance;
  vector<lower=0> amf_number_of_malaria_deaths;
  vector<lower=0> amf_number_of_malaria_deaths_under_5;
  real<lower=0,upper=1> amf_relative_efficacy_of_llin_for_over_5;
  real<lower=0> amf_reduction_of_malaria_under_5;

}
model {
  // GiveDirectly
  givedirectly_proportion ~ beta(10, 2);
  givedirectly_size_of_transfer ~ normal(1000, 200);
  givedirectly_household_size ~ normal(4.7, 1);
  givedirectly_transfers_invested ~ beta(10, 15.64);
  givedirectly_roi ~ beta(10, 90);
  givedirectly_consumption_per_capita ~ normal(285.92, 70);
  givedirectly_investment_duration ~ normal(10, 2);
  givedirectly_percent_of_investment_returned ~ beta(2, 8);
  givedirectly_discount_negative_spoiler ~ beta(1, 19);

  // AMF
  // These have issues with not always adding up to 100%
  proportion_each_location ~ beta(2, 2 / [0.72, 0.06, 0.05, 0.17]' - 2);
  amf_cost_covered ~ beta (2, 2 / [0.43, 0.52, 0.49, 0.54]' - 2)
  amf_cost_covered_philanthropic ~ beta (2, 2 / [0.03, 0, 0, 0]' - 2)
  amf_cost_llin = normal([5.25, 4.50, 4.86, 4.29]', 0.20);
  real<lower=0> amf_covered_by_net = normal(1.8,0.1);
  amf_population_under_5 ~ beta (2, 2 / [0.16, 0.17, 0.14, 0.18]' - 2);
  amf_population_between_5_9 ~ beta (2, 2 / [0.15, 0.15, 0.14, 0.16]' - 2);
  amf_population_between_10_14 ~ beta (2, 2 / [0.13, 0.13, 0.12, 0.14]' - 2);
  amf_coverage_years_llin ~ normal ([1.90, 2.11, 2.11, 2.11]', 0.2);
  amf_relative_risk_of_death_averted_per_under_5 ~ normal(0.17, 0.1);
  amf_mortality_under_5_before_nets ~ normal([25.0,25.6,17.6,19.3]', 2);
  amf_mortality_under_5_after_nets ~ normal([13.3, 14.1, 8.3, 7.5]', 2);
  
  amf_percent_own_nets_without_amf ~ beta(2, 8);
  amf_percent_own_nets_with_amf ~ beta(2, 2);

  amf_net_use_adjustment ~ beta(2,0.222);
  amf_internal_validity ~ beta(2,0.1052);
  amf_external_validity ~ beta(2,0.1052);

  amf_mortality_attributed_vs_context ~ normal([1.32, 1.17, 1.63, 1.25]', 0.3]);
  amf_efficacy_reduction_due_to_resistance ~ beta(2, 2 / [1.32, 1.17, 1.63, 1.25]' - 2);

  amf_number_of_malaria_deaths ~ normal([81226, 11355, 6904, 22237]', 100);
  amf_number_of_malaria_deaths_under_5 ~ normal([48656, 6746, 3117, 13926]', 100);
  amf_relative_efficacy_of_llin_for_over_5 ~ beta(2, 0.5);

  amf_reduction_of_malaria_under_5 ~ beta(2, 2.4);
}
generated quantities {
  // GiveDirectly
  real givedirectly_funds_available = donation_size * givedirectly_proportion;
  real givedirectly_transfer_per_person = givedirectly_size_of_transfer / givedirectly_household_size;
  real givedirectly_amount_invested = givedirectly_transfer_per_person * givedirectly_transfers_invested;
  real givedirectly_increase_of_consumption = (1 - givedirectly_transfers_invested) * givedirectly_transfers_invested;
  real givedirectly_consumption_from_roi = givedirectly_roi * givedirectly_amount_invested;
  real givedirectly_increase_ln_consumption = log(givedirectly_consumption_per_capita + givedirectly_increase_of_consumption) - log(givedirectly_consumption_per_capita);
  real givedirectly_increase_ln_consumption_roi = log(givedirectly_consumption_per_capita + givedirectly_consumption_from_roi) - log(givedirectly_consumption_per_capita);
  real givedirectly_pv_of_increase_in_ln_consumption = pv(givedirectly_increase_ln_consumption_roi, discount_rate, givedirectly_investment_duration);
  real givedirectly_pv_of_ln_increase_last_year = (log(givedirectly_consumption_per_capita+givedirectly_amount_invested*(givedirectly_roi +givedirectly_percent_of_investment_returned))- log(givedirectly_consumption_per_capita)) / pow(1 + discount_rate, givedirectly_investment_duration);
  real givedirectly_pv_of_all_increase = givedirectly_pv_of_ln_increase_last_year + givedirectly_pv_of_increase_in_ln_consumption;
  real givedirectly_total_present_value_of_cash_transfer = givedirectly_increase_ln_consumption + givedirectly_pv_of_all_increase;
  real givedirectly_value_discounting_spoiler = (1 - givedirectly_discount_negative_spoiler) * givedirectly_total_present_value_of_cash_transfer;
  real givedirectly_consumption_per_household = givedirectly_value_discounting_spoiler * givedirectly_household_size;

  real givedirectly_transfers_made = givedirectly_funds_available / givedirectly_size_of_transfer;
  real givedirectly_increase_in_ln_consumption = givedirectly_transfers_made * givedirectly_consumption_per_household;

  real givedirectly_value_generated = givedirectly_increase_in_ln_consumption * value_of_ln_consumption;
  real givedirectly_value_per_grand = givedirectly_value_generated / donation_size * 1000;

  // AMF
  vector amf_donation_to_amf_per_country = proportion_each_location * donation_size;
  vector amf_total_spending_all_contributors = amf_donation_to_amf_per_country / amf_cost_covered;
  vector amf_cost_per_person_covered = amfcost_llin / amf_covered_by_net; 
  vector amf_total_covered = amf_total_spending_all_contributors / amf_cost_per_person_covered; 
  real amf_overall_covered = sum(amf_total_covered);
  vector amf_percent_covered_each_country = amf_total_covered / amf_overall_covered;

  vector amf_population_between_5_14 = amf_population_between_5_9 + amf_population_between_10_14;

  vector amf_children_under_5_covered = amf_total_covered * amf_population_under_5;
  vector amf_children_between_5_14_covered = amf_total_covered * amf_population_between_5_14;

  vector amf_person_years_under_5 = amf_coverage_years_llin * amf_children_under_5_covered;
  vector amf_person_years_between_5_14 = amf_coverage_years_llin * amf_children_between_5_14_covered;
  vector amf_person_years_under_15 = amf_person_years_under_5 + amf_person_years_between_5_14;

  vector amf_mortality_decrease = amf_mortality_under_5_after_nets / amf_mortality_under_5_before_nets;
  vector amf_counterfactual_mortality = amf_mortality_under_5_before_nets + amf_mortality_under_5_after_nets * (1 - amf_mortality_decrease) * amf_portion_of_mortality_attribute_to_nets;

  real amf_final_adjustment_existing_nets = 1 - amf_percent_own_nets_with_amf * amf_percent_own_nets_without_amf;

  vector amf_deaths_averted_per_1000_under_5 = amf_relative_risk_of_death_averted_per_under_5 * amf_counterfactual_mortality * amf_final_adjustment_existing_nets * amf_internal_validity * amf_external_validity * amf_net_use_adjustment * amf_mortality_attributed_vs_context * (1 - amf_efficacy_reduction_due_to_resistance);

  vector amf_total_deaths_under_5_averted = (amf_person_years_under_5 / 1000) * amf_deaths_averted_per_1000_under_5;
  vector amf_value_under_5_deaths_averted = value_of_under_5_death_averted * amf_total_deaths_under_5_averted;

  vector amf_deaths_over_5_malaria = amf_number_of_malaria_deaths - amf_number_of_malaria_deaths_under_5;
  vector amf_ratio_of_under_5_to_over_5_deaths = amf_deaths_over_5_malaria / amf_number_of_malaria_deaths_under_5;

  vector amf_deaths_over_5_averted = amf_total_deaths_under_5_averted * amf_relative_efficacy_of_llin_for_over_5 * amf_ratio_of_under_5_to_over_5_deaths;

  vector amf_value_generated_from_over_5_deaths_averted = amf_deaths_over_5_averted * value_of_over_5_death_averted;
  vector amf_total_deaths_averted = amf_deaths_over_5_averted + amf_total_deaths_under_5_averted;

  vector amf_expected_reduction_in_malaria = amf_reduction_of_malaria_under_5 * amf_final_adjustment_existing_nets * amf_net_use_adjustment * amf_internal_validity * amf_external_validity * amf_mortality_attributed_vs_context * (1 - amf_efficacy_reduction_due_to_resistance);
  

}
