## commruleR package, for the IBEEM Community Assembly Rules project
## Rscript that preparse data to be saved in the /data folder of this package
## used for working with the Comm Assembly Rules project
#
#  Author: Pat Bills, MSU
#  collaborators : see DESCRIPTION of this package
#  v1 August 2024 working version
#  v2 September 2024 start on making package generic
#  v3 March 2025 re-factor to functions add complete documentation

# requirements:
#  - devtools package
#  - this package commruleR dependencies installed, install with devtools::install()

# inputs: set the TEST_TEMPLATE_URL variable in .Renviron
# outputs:
#  - will add 4 new data frames into the environments
#  - will write 5 rda (R data) files to /data folder

# usage:  These functions are for pre-packaging and not part of the package.
#  0. Load the functins in this package with either devtools::load_all() or
#     install the package using devtools::load
#  1. source this script
#  2. if working with CommAssemblyRules project, first set the variable
#     'TEST_TEMPLATE_URL' in the environment or in .Renviron file (and Restart R)
#  3. if working with CommAssemblyRules project, run the function
#     create_comm_assembly_rules_data() in the console, optionally providing your
#      email used to connect to google workspace.  see ?gdrive_setup
#  4. if building the package for generic use, run the function
#     save_iris_species_df() which converts the R IRIS data into separate data frames



'# create  CommAssemblyRules project specific data files
'#
'# these are only useful for the CommAssemblyRules project data column specifications
'# 1. authenticate with google.
'# if you are already authenticated they will simply return True.
'# If you have not run this package in a while or have nto authenticated to google
'# workspace in a while, this will require your interaction (e.g. it
'# can't be run automatically). You may be asked to either
'# 1) open a browser or
'# 2) select an email you'd used previously (select 1 or 2, 1 opening  browser)
create_comm_assembly_rules_data <- function(drive_email = NULL){

  # authenticate with google
  gdrive_setup(drive_email)
  gsheet_auth_setup(drive_email)

  commassembly_rules_template <- Sys.getenv('TEST_TEMPLATE_URL')
  if(commassembly_rules_template == ""){
    warning('please set the variable TEST_TEMPLATE_URL to point to the template
            sheet containing metadata')
  }

  commassembly_rules_biomass_str <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'biomass_str')
  usethis::use_data(commassembly_rules_biomass_str, overwrite = TRUE)
  commassembly_rules_env_str <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'env_str')
  usethis::use_data(commassembly_rules_env_str, overwrite = TRUE)
  biomass_lookup <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'biomass_lookup')
  usethis::use_data(biomass_lookup, overwrite = TRUE)
  species_dictionary <-  googlesheets4::read_sheet(googledrive::as_id(commassembly_rules_template), sheet = 'species_dictionary')
  usethis::use_data(species_dictionary, overwrite = TRUE)


  # validation rules
  biomass_validator_file <- file.path('inst/rules/biomass_validation_rules.yaml')
  biomass_validator <- validate::validator(.file= biomass_validator_file )
  usethis::use_data(biomass_validator, overwrite = TRUE)

  env_validator_file <- file.path('inst/rules/env_validation_rules.yaml')
  env_validator <- validate::validator(.file= env_validator_file )
  usethis::use_data(env_validator, overwrite = TRUE)
}

####
# generic data for package testing and demonstration

prep_iris_species_df <-function(genus){
  df <- data.frame(iris3[,,genus])
  df$group_id <- rep(genus, nrow(df))
  df$whos <- rep('ESA', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  df$site <- rep('Missouri Botanical Garden', nrow(df))
  return(df)
}

save_iris_species_df <-function(raw_data_dir = 'data-raw'){
  readr::write_csv( prep_iris_species_df("Setosa"), file.path(raw_data_dir,  "Setosa.csv"))
  readr::write_csv( prep_iris_species_df("Versicolor"), file.path(raw_data_dir,  "Versicolor.csv"))
  readr::write_csv( prep_iris_species_df("Virginica"), file.path(raw_data_dir,  "Virginica.csv"))
}
