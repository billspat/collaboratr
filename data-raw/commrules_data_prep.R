## commruleR package, for the IBEEM Community Assembly Rules project
## code to prepare data to be saved in the /data folder of this package
## from the main folder of this page, sources this file to create data files

# this will require authentication to google drive, see gdrive.R and
# gsheet_auth_setup(drive_email) function

raw_data_dir = 'data-raw'

# data column specifications
commassembly_rules_template <- Sys.getenv('TEST_TEMPLATE_URL')
commassembly_rules_biomass_str <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'biomass_str')
usethis::use_data(commassembly_rules_biomass_str, overwrite = TRUE)
commassembly_rules_env_str <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'env_str')
usethis::use_data(commassembly_rules_env_str, overwrite = TRUE)
biomass_lookup <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'biomass_lookup')
usethis::use_data(biomass_lookup, overwrite = TRUE)
species_dictionary <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'species_dictionary')
usethis::use_data(species_dictionary, overwrite = TRUE)


# validation rules?
biomass_validator_file <- file.path('inst/rules/biomass_validation_rules.yaml')
biomass_validator <- validate::validator(.file= biomass_validator_file )
usethis::use_data(biomass_validator, overwrite = TRUE)

env_validator_file <- file.path('inst/rules/env_validation_rules.yaml')
env_validator <- validate::validator(.file= env_validator_file )
usethis::use_data(env_validator, overwrite = TRUE)


prep_iris_species_df <-function(genus){
  df <- data.frame(iris3[,,genus])
  df$group_id <- rep(genus, nrow(df))
  df$whos <- rep('ESA', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  return(df)
}


readr::write_csv( prep_iris_species_df("Setosa"), file.path(raw_data_dir,  "Setosa.csv"))
readr::write_csv( prep_iris_species_df("Versicolor"), file.path(raw_data_dir,  "Versicolor.csv"))
readr::write_csv( prep_iris_species_df("Virginica"), file.path(raw_data_dir,  "Virginica.csv"))

