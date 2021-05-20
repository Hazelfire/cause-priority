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
transformed data {
  int amf_mission_count = 4;
}
parameters {
  // Give Directly
  real<lower=0,upper=1> givedirectly_proportion;
  real<lower=0> givedirectly_size_of_transfer;
  real<lower=0> givedirectly_household_size;
  r  vector<lower=0,upper=1>[amf_mission_count] amf_malaria_prevalence_between_5_9;
eal<lower=0,upper=1> givedirectly_transfers_invested;
   vector<lower=0,upper=1>[amf_mission_count] amf_malaria_prevalence_between_5_9;
 real<lower=0> givedirectly_consumption_per_capita;
  real<lower=0,upper=1> givedirectly_roi;
  real<lower=0> givedirectly_investment_duration;
  real<lower=0,upper=1> givedirectly_percent_of_investment_returned;
  real<lower=0,upper=1> givedirectly_discount_negative_spoiler;

  // AMF
  vector<lower=0,upper=1>[amf_mission_count] proportion_each_location;
  vector<lower=0,upper=1>[amf_mission_count] amf_cost_covered;
  vector<lower=0,upper=1>[amf_mission_count] amf_cost_covered_philanthropic;
  vector<lower=0>[amf_mission_count] amf_cost_llin;
  real<lower=0> amf_covered_by_net;
  vector<lower=0,upper=1>[amf_mission_count] amf_population_under_5;
  vector<lower=0,upper=1>[amf_mission_count] amf_population_between_5_9;
  vector<lower=0,upper=1>[amf_mission_count] amf_population_between_10_14;
  vector<lower=0>[amf_mission_count] amf_coverage_years_llin;
  real<lower=0> amf_relative_risk_of_death_averted_per_under_5;
  vector<lower=0>[amf_mission_count] amf_mortality_under_5_before_nets;
  vector<lower=0>[amf_mission_count] amf_mortality_under_5_after_nets;
  real<lower=0> amf_portion_of_mortality_attribute_to_nets;
  real<lower=0,upper=1> amf_percent_own_nets_without_amf;
  real<lower=0,upper=1> amf_percent_own_nets_with_amf;
  real<lower=0,upper=1> amf_net_use_adjustment;
  real<lower=0,upper=1> amf_internal_validity;
  real<lower=0,upper=1> amf_external_validity;
  vector<lower=0>[amf_mission_count] amf_mortality_attributed_vs_context;
  vector<lower=0>[amf_mission_count] amf_efficacy_reduction_due_to_resistance;
  vector<lower=0>[amf_mission_count] amf_number_of_malaria_deaths;
  vector<lower=0>[amf_mission_count] amf_number_of_malaria_deaths_under_5;
  real<lower=0,upper=1> amf_relative_efficacy_of_llin_for_over_5;
  real<lower=0,upper=1> amf_reduction_of_malaria_under_5;
  vector<lower=0,upper=1>[amf_mission_count] amf_malaria_prevalence_under_5;
  vector<lower=0,upper=1>[amf_mission_count] amf_malaria_prevalence_between_5_9;
  vector<lower=0,upper=1>[amf_mission_count] amf_malaria_prevalence_between_10_14;
  real<lower=0,upper=1> amf_increase_malaria_without_llin;
  real<lower=0,upper=1> amf_increase_in_income_from_reducing_malaria_under_15;
  real<lower=0,upper=1> amf_replicatability_adjustment_malaria_income;
  real<lower=0> amf_years_until_long_term_benefits;
  real<lower=0> amf_duration_of_long_term_benifits;
  real<lower=0> amf_multiplier_resource_sharing;

  // Deworm the World
  real<lower=0> deworm_treatment_effect_on_ln_income;
  real<lower=0,upper=1> deworm_coverage_in_treatment_group;
  real<lower=0,upper=1> deworm_coverage_in_control_group;
  real<lower=0,upper=1> deworm_replicatability_adjustment;
  real<lower=0,upper=1> deworm_year_adjustment_treated;
  real<lower=0> deworm_years_until_benefits;
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
  proportion_each_location ~ beta(2, 2.0 ./ [0.72, 0.06, 0.05, 0.17]' - 2.0);
  amf_cost_covered ~ beta (2, 2.0 ./ [0.43, 0.52, 0.49, 0.54]' - 2.0);
  amf_cost_covered_philanthropic ~ beta (2, 2.0 ./ [0.03, 0.0001, 0.0001, 0.0001]' - 2.0);
  amf_cost_llin ~ normal([5.25, 4.50, 4.86, 4.29]', 0.20);
  amf_covered_by_net ~ normal(1.8,0.1);
  amf_population_under_5 ~ beta (2, 2.0 ./ [0.16, 0.17, 0.14, 0.18]' - 2.0);
  amf_population_between_5_9 ~ beta (2, 2.0 ./ [0.15, 0.15, 0.14, 0.16]' - 2.0);
  amf_population_between_10_14 ~ beta (2, 2.0 ./ [0.13, 0.13, 0.12, 0.14]' - 2.0);
  amf_coverage_years_llin ~ normal ([1.90, 2.11, 2.11, 2.11]', 0.2);
  amf_relative_risk_of_death_averted_per_under_5 ~ normal(0.17, 0.1);
  amf_mortality_under_5_before_nets ~ normal([25.0,25.6,17.6,19.3]', 2);
  amf_mortality_under_5_after_nets ~ normal([13.3, 14.1, 8.3, 7.5]', 2);
  amf_portion_of_mortality_attribute_to_nets ~ beta(2, 6);
  
  amf_percent_own_nets_without_amf ~ beta(2, 8);
  amf_percent_own_nets_with_amf ~ beta(2, 2);

  amf_net_use_adjustment ~ beta(2,0.222);
  amf_internal_validity ~ beta(2,0.1052);
  amf_external_validity ~ beta(2,0.1052);

  amf_mortality_attributed_vs_context ~ normal([1.32, 1.17, 1.63, 1.25]', 0.3);
  amf_efficacy_reduction_due_to_resistance ~ normal([1.32, 1.17, 1.63, 1.25]', 0.3);

  amf_number_of_malaria_deaths ~ normal([81226, 11355, 6904, 22237]', 100);
  amf_number_of_malaria_deaths_under_5 ~ normal([48656, 6746, 3117, 13926]', 100);
  amf_relative_efficacy_of_llin_for_over_5 ~ beta(2, 0.5);

  amf_reduction_of_malaria_under_5 ~ beta(2, 2.4);

  amf_malaria_prevalence_under_5 ~ beta(2, 2.0 ./ [0.25, 0.28, 0.38, 0.23]' - 2.0);
  amf_malaria_prevalence_between_5_9 ~ beta(2, 2.0 ./ [0.28, 0.30, 0.42, 0.26]' - 2.0);
  amf_malaria_prevalence_between_10_14 ~ beta(2, 2.0 ./ [0.26, 0.28, 0.39, 0.24]' - 2.0);
  amf_increase_malaria_without_llin ~ beta (2, 8);

  amf_increase_in_income_from_reducing_malaria_under_15 ~ beta(2, 89);
  amf_percent_own_nets_without_amf ~ beta(2, 8);                                
  amf_replicatability_adjustment_malaria_income ~ beta(2, 1.8);
  amf_years_until_long_term_benefits ~ normal(10, 3);
  amf_duration_of_long_term_benifits ~ normal(40, 3);

  amf_multiplier_resource_sharing ~ normal(2, 0.5);

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
  vector[amf_mission_count] amf_donation_to_amf_per_country = proportion_each_location * donation_size;
  vector[amf_mission_count] amf_total_spending_all_contributors = amf_donation_to_amf_per_country ./ amf_cost_covered;
  vector[amf_mission_count] amf_cost_per_person_covered = amf_cost_llin ./ amf_covered_by_net; 
  vector[amf_mission_count] amf_total_covered = amf_total_spending_all_contributors ./ amf_cost_per_person_covered; 
  real amf_overall_covered = sum(amf_total_covered);
  vector[amf_mission_count] amf_percent_covered_each_country = amf_total_covered ./ amf_overall_covered;

  vector[amf_mission_count] amf_population_between_5_14 = amf_population_between_5_9 + amf_population_between_10_14;

  vector[amf_mission_count] amf_children_under_5_covered = amf_total_covered .* amf_population_under_5;
  vector[amf_mission_count] amf_children_between_5_14_covered = amf_total_covered .* amf_population_between_5_14;

  vector[amf_mission_count] amf_person_years_under_5 = amf_coverage_years_llin .* amf_children_under_5_covered;
  vector[amf_mission_count] amf_person_years_between_5_14 = amf_coverage_years_llin .* amf_children_between_5_14_covered;
  vector[amf_mission_count] amf_person_years_under_15 = amf_person_years_under_5 + amf_person_years_between_5_14;

  vector[amf_mission_count] amf_mortality_decrease = amf_mortality_under_5_after_nets ./ amf_mortality_under_5_before_nets;
  vector[amf_mission_count] amf_counterfactual_mortality = amf_mortality_under_5_before_nets + amf_mortality_under_5_after_nets .* (1 - amf_mortality_decrease) * amf_portion_of_mortality_attribute_to_nets;

  real amf_final_adjustment_existing_nets = 1 - amf_percent_own_nets_with_amf * amf_percent_own_nets_without_amf;

  vector[amf_mission_count] amf_deaths_averted_per_1000_under_5 = amf_relative_risk_of_death_averted_per_under_5 * amf_final_adjustment_existing_nets * amf_internal_validity * amf_external_validity * amf_net_use_adjustment * amf_counterfactual_mortality .* amf_mortality_attributed_vs_context .* (1 - amf_efficacy_reduction_due_to_resistance);

  vector[amf_mission_count] amf_total_deaths_under_5_averted = (amf_person_years_under_5 / 1000) .* amf_deaths_averted_per_1000_under_5;
  vector[amf_mission_count] amf_value_under_5_deaths_averted = value_of_under_5_death_averted * amf_total_deaths_under_5_averted;

  vector[amf_mission_count] amf_deaths_over_5_malaria = amf_number_of_malaria_deaths - amf_number_of_malaria_deaths_under_5;
  vector[amf_mission_count] amf_ratio_of_under_5_to_over_5_deaths = amf_deaths_over_5_malaria ./ amf_number_of_malaria_deaths_under_5;

  vector[amf_mission_count] amf_deaths_over_5_averted = amf_relative_efficacy_of_llin_for_over_5 * amf_total_deaths_under_5_averted .* amf_ratio_of_under_5_to_over_5_deaths;

  vector[amf_mission_count] amf_value_generated_from_over_5_deaths_averted = amf_deaths_over_5_averted * value_of_over_5_death_averted;
  vector[amf_mission_count] amf_total_deaths_averted = amf_deaths_over_5_averted + amf_total_deaths_under_5_averted;

  vector[amf_mission_count] amf_expected_reduction_in_malaria = amf_reduction_of_malaria_under_5 * amf_final_adjustment_existing_nets * amf_net_use_adjustment * amf_internal_validity * amf_external_validity * amf_mortality_attributed_vs_context .* (1 - amf_efficacy_reduction_due_to_resistance);
  
  vector[amf_mission_count] amf_malaria_prevalence_between_5_14 = amf_malaria_prevalence_between_5_9 .* (amf_population_between_5_9 ./ amf_population_between_5_14) + amf_malaria_prevalence_between_10_14 .* (amf_population_between_10_14 ./ amf_population_between_5_14);

  vector[amf_mission_count] amf_counterfactual_malaria_under_5 = amf_malaria_prevalence_under_5 * (1 + amf_increase_malaria_without_llin);
  vector[amf_mission_count] amf_counterfactual_malaria_between_5_14 = amf_malaria_prevalence_between_5_14 * (1 + amf_increase_malaria_without_llin);

  vector[amf_mission_count] amf_percent_reduction_probability_under_5 = amf_counterfactual_malaria_under_5 .* amf_expected_reduction_in_malaria;
  vector[amf_mission_count] amf_percent_reduction_probability_between_5_14 = amf_counterfactual_malaria_between_5_14 .* amf_expected_reduction_in_malaria;

  vector[amf_mission_count] amf_malaria_reduction_under_5 = amf_percent_reduction_probability_under_5 .* amf_person_years_under_5;
  vector[amf_mission_count] amf_malaria_reduction_between_5_14 = amf_percent_reduction_probability_between_5_14 .* amf_person_years_between_5_14;

  real amf_increase_in_ln_income_under_15 = log(1 + amf_increase_in_income_from_reducing_malaria_under_15) * amf_replicatability_adjustment_malaria_income;

  real amf_benefit_years_outcome_under_15 = amf_increase_in_ln_income_under_15 / pow(1 + discount_rate, amf_years_until_long_term_benefits);

  real amf_pv_of_benefits_under_15 = pv(amf_benefit_years_outcome_under_15,discount_rate, amf_duration_of_long_term_benifits);

  real amf_pv_of_benefits_household = amf_multiplier_resource_sharing * amf_pv_of_benefits_under_15;

  vector[amf_mission_count] amf_total_value_income_under_5_pv = amf_pv_of_benefits_household * amf_malaria_reduction_under_5;
  vector[amf_mission_count] amf_total_value_income_between_5_14_pv = amf_pv_of_benefits_household * amf_malaria_reduction_between_5_14;

  vector[amf_mission_count] amf_total_value_income = value_of_ln_consumption * (amf_total_value_income_under_5_pv + amf_total_value_income_between_5_14_pv);

  real amf_total_units_of_value = sum(amf_total_value_income) + sum(amf_value_generated_from_over_5_deaths_averted) + sum(amf_value_under_5_deaths_averted);

  int amf_better_than_givewell = amf_total_units_of_value > givedirectly_value_generated;
}
