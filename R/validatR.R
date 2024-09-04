
#  need method to read in column definitions

read_column_definitions_sheet<-function(gurl){

}


read_column_definitions<-function(df){

}






#' Example Column Definitions
#'
#' list of column names with meanings, data type, units and examples
#'
#' @format ## `example_data_definition`
#' A data frame 40-ish rows and 4 columns:
#' \describe{
#'   \item{col_name}{name of column in biomass}       ""
#'   \item{col_description}{desc}
#'   \item{col_type}{R data type}
#'   \item{example}{what may go in the data}
#'   \item{notes}{misc field}
#' }
"example_data_definition"



#' read in two-tab data sheet from meta analysis from google drive
#'
#' data sheets in google drive have data tab (1) and group definition tab (2)
#'
#' @param sheeturl the url of of the google sheet that has commecologyRULES data
#' @param has_description_line T/F datasheets use first row with explanatory text in google sheet, remove if TRUE.  defaults to TRUE
#' @param drive_email the email to use for google drive log-in, which is the institution that setup the project
#'
#' @returns list of data frames, on for each google sheet tab
#' @export
read_data_sheet<-function(sheet_url, has_description_line = TRUE, drive_email=NULL){
  # gdrive_setup(drive_email = drive_email)

  data_df <- read_gsheet_by_url(gurl = sheet_url, sheet_tab_number = 1, has_description_line = has_description_line )
  group_df <- read_gsheet_by_url(gurl = sheet_url, sheet_tab_number = 2, has_description_line = has_description_line)

  return(list('data' = biomass_df, 'group' = env_df))

}


#' @export
type_name_to_fn <- function(type_str) {
  if(type_str == 'character') return(readr::col_character)
  if(type_str == 'factor') return(readr::col_factor)
  if(type_str == 'double') return(readr::col_double)
  if(type_str == 'integer') return(readr::col_integer)
  return(NA)
}




#' @export
read_data_specification<- function(csv_file){
  spec_df <- readr::read_csv(csv_file, show_col_types = FALSE)
  stopifnot("col_name" %in% names(spec_df))
  return(spec_df)
}


data_specification_column_spec <- function(spec_df) {
  paste0(substr(spec.df$col_type, 1, 1), collapse = '')
}


#' validate columns against data definition
#'
#' @param data_df data frame following data definition
#' @param spec_df data frame of table specification
#' @export
validate_data_columns<- function(data_df, spec_df){

  stopifnot("col_name" %in% names(spec_df))
  return(  identical(sort(spec_df$col_name), sort(names(data_df))) )

}


#' validate data df
#'
#' use the validate package to check a file against a set of rules
#' @param data_df dataframe of biomass data
#' @param spec_df data frame of table specification
#' @param validation_rules file with validation rules in it.
#' @export
validate_data<- function(data_df, spec_df, validation_rules ){

  if(!validate_data_columns(data_df, spec_df)){
    warning("column names don't match specification")
    #TODO display columns that don't match
  }

  validation_results <- validate::confront(data_df, validation_rules)
  validate::summary(validation_results)

  return(validation_results)

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
