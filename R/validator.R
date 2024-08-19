
#' biomass columns
#'
#' @export
biomass_column_names <- c("spp_who", "spp_date", "ID_new", "source", "external_trt", "trt_type", "reponse_var", "site", "spp_biomass", "f_spp_name", "f_nat_inv", "f_num_indiv", "c_spp_name", "c_nat_inv", "c_num_indiv", "biomass_type", "response_mean", "response_transformation", "response_mean_unit", "response_var", "response_var_unit", "sample_size", "nutrient_general", "nutrient_compound", "nutrient1_mean", "nutrient2_mean", "nutrient3_mean", "nutrient_unit", "nutrient_interval_days", "nutrient_addition_duration", "ext_treatment_mean", "ext_treatment_unit", "notes")


#' Column Definitions for CommecologyRULEs biomass datasets
#'
#' list of column names with meanings, data type, units and examples
#'
#' @format ## `commecology_rules_biomass_str`
#' A data frame 40-ish rows and 4 columns:
#' \describe{
#'   \item{col_name}{name of column in biomass}       ""
#'   \item{col_description}{desc}
#'   \item{data_str}{R data type}
#'   \item{example}{what may go in the data}
#' }
"commecology_rules_biomass_str"

# #' biomass field definitions
# #' @export
# biomass_fields <- read.csv('data/commecology_rules_biomass_str.csv')


# #' default file with validation rules for biomass data
# #'
# #' @export
# biomass_validation_file <- system.file('rules', 'biomass_validation_rules.yaml', package='commruleR')

# #' default file with validation rules for env data
# #'
# #' @export
# env_validation_file <- system.file('rules', 'env_validation_rules.yaml', package='commruleR')


#' read in two data tabs (only) of  meta-data analysis google sheet
#'
#' @param sheeturl the url of of the google sheet that has commecologyRULES data
#' @param has_description_line T/F datasheets use first row with explanatory text in google sheet, remove if TRUE.  defaults to TRUE
#' @param drive_email the email to use for google drive log-in, which is the institution that setup the project
#'
#' @returns list of data frames, on for each google sheet tab
#' @export
read_commrules_sheet<-function(sheet_url, has_description_line = TRUE, drive_email=NULL){
  # gdrive_setup(drive_email = drive_email)

  biomass_df <- read_gsheet_by_url(gurl = sheet_url, sheet_tab_number = 1, has_description_line = has_description_line )
  env_df <- read_gsheet_by_url(gurl = sheet_url, sheet_tab_number = 2, has_description_line = has_description_line)

  return(list('biomass' = biomass_df, 'env' = env_df))
}

#' validate columns present for biomass data
#'
#' @param biomass_data data frame of biomass data from commecologyRules
#' @export
validate_biomass_columns<- function(biomass_data){
  return(  identical(sort(commecology_rules_biomass_str$col_name), sort(names(biomass_data))) )
}

# TODO change this function to take a validator object instead of

#' validate biomass data
#'
#' use the validate package to check a file against the
#' @param biomass_data dataframe of biomass data
#' @param validation_file optional file with validation rules in it.
#' @export
validate_biomass_data<- function(biomass_data, validation_file = NULL ){
  if(is.null(validation_file)) {
    validation_file = system.file('rules', 'biomass_validation_rules.yaml', package='commruleR')
  }
  biomass_rules <- validate::validator(.file = validation_file)
  validation_results <- validate::confront(biomass_data, biomass_rules)
  validate::summary(validation_results)
  return(validation_results)

}
#' validate env columns
#'
#' check that all columns present in imported env data
#' @param env_data data frame from imported env spreadsheet
#' @export
validate_env_columns<- function(env_data){
  env_columns <- c('env_who','env_date','ID_new','exp_type','biome_type','country','state_city_province','latitude','longitude','coord_units','site','rainshelter','avg_rep_temp_C','avg_rep_ppt_mm','avg_rep_elev_m','year_start','year_end','exp_duration_days','notes')
  return(  identical(sort(env_columns), sort(names(env_data))) )
}

#' run all validation checks for biomass
#'
#' @param biomass_df data frame with biomass data
#' @param validation_file optional file to read for validation, will read from inst/rules if not sent
#' @returns boolean TRUE if all validation checks pass
#' @export
validate_biomass<- function(biomass_df, validation_file = NULL){
  if(! validate_biomass_columns(biomass_df))
    warning("Columns in sheet don't match expected list of columns")
    return(FALSE)

  r <- validate_biomass_data(biomass_data = biomass_df, validation_file = validation_file)
  return(r)

}
