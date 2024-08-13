
#' constants for validation
biomass_column_names <- c("spp_who", "spp_date", "ID_new", "source", "external_trt", "trt_type", "reponse_var", "site", "spp_biomass", "f_spp_name", "f_nat_inv", "f_.indiv", "c_spp_name", "c_nat_inv", "c_.indiv", "biomass_type", "response_mean", "response_transformation", "response_mean_unit", "response_var", "response_var_unit", "sample_size", "nutrient_general", "nutrient_compound", "nutrient1_mean", "nutrient2_mean", "nutrient3_mean", "nutrient_unit", "nutrient_interval_days", "nutrient_addition_duration", "ext_treatment_mean", "ext_treatment_unit", "notes")
biomass_validation_file <- 'inst/biomass_validation_rules.yaml'
env_validation_file <- 'int/env_validation_rules.yml'


#' read in one tab (only) of  meta-data analysis google sheet
#'
#' @param sheeturl the url of of the google sheet - each tab has it's own URL!
#' @param remove_row_one datasheets use first row with explanatory text in google sheet, remove if TRUE.  defaults to TRUE
#' @param drive_email the email to use for google drive log-in, which is the institution that setup the project
#'
#' @returns data frame
read_commrules_sheet<-function(sheet_url, has_comment_line = TRUE, drive_email=NULL){
  gdrive_setup(drive_email = drive_email)
  commrules_df <- read_gcsv(sheet_url, has_comment_line = has_comment_line)
  return(commrules_df)
}


validate_biomass_columns<- function(biomass_data){
  return(  identical(sort(biomass_column_names), sort(names(biomass_data))) )
}


validate_biomass_data<- function(biomass_data, validation_file = biomass_validation_file ){
  biomass_rules <- validate::validator(.file = validation_file)
  validation_results <- validate::confront(biomass_data, biomass_rules)
  summary(validation_results)
}


validate_env_columns<- function(env_data){
  env_columns <- c('env_who','env_date','ID_new','exp_type','biome_type','country','state_city_province','latitude','longitude','coord_units','site','rainshelter','avg_rep_temp_C','avg_rep_ppt_mm','avg_rep_elev_m','year_start','year_end','exp_duration_days','notes')
  return(  identical(sort(env_columns), sort(names(env_data))) )
}


validate_biomass<- function(biomass_df){
  if(! validate_biomass_columns(biomass_df))
    warning("Columns in sheet don't match expected list of columns")
    return(FALSE)
}
