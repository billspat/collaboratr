## code to prepare data

raw_data_dir = 'data-raw'

commassembly_rules_template <- Sys.getenv('TEST_TEMPLATE_URL')

commassembly_rules_biomass_str <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'biomass_str')
#   readr::read_csv(file.path(raw_data_dir, 'biomass_spec.csv'))
usethis::use_data(commassembly_rules_biomass_str, overwrite = TRUE)
commassembly_rules_env_str <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'env_str')
usethis::use_data(commassembly_rules_env_str, overwrite = TRUE)

# validation rules?
biomass_validator_file <- file.path(raw_data_dir, 'biomass_validation_rules.yaml')
biomass_validator <- validate::validator(.file= biomass_validator_file )
usethis::use_data(biomass_validator, overwrite = TRUE)


prep_iris_species_df <-function(genus){
  df <- data.frame(iris3[,,genus])
  df$group_id <- rep(genus, nrow(df))
  df$whos <- rep('ESA', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  return(df)
}


readr::write_csv( prep_iris_species_df("Setosa"), "data_raw/Setosa.csv")
readr::write_csv( prep_iris_species_df("Versicolor"), "data_raw/Versicolor.csv")
readr::write_csv( prep_iris_species_df("Virginica"), "data_raw/Virginica.csv")

