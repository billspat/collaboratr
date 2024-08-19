## code to prepare data

commecology_rules_biomass_str <- readr::read_csv('data-raw/commecology_rules_biomass_str.csv')
usethis::use_data(commecology_rules_biomass_str, overwrite = TRUE)
