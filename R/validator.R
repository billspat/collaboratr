## MSU IBEEM : Community Assembly Rules project
## Validation workflow functions

# this R project is constructed as an R package, but this particular script
# does not have any exported functions like a package would.  This is for
# 1) it's still under development
# 2) it's very specific to the data for the Community Assembly Rules project

# ultimately this will be written as part of a vignette or sample code that uses
# the validation rules and column definitions for this project as examples

# to use these functions
#  1. ensure that you have permissions in GCP and keys in .Renviron
#    in .Renviron also set the URL for the google sheet with the list of sheet
#    urls to validate
#  2. ensure you have the most up-to-date versions of the data template
#    run the script data-raw/commrules_data_prep.R to generate new data/*.rda
#  3. source this file
#    that will automatically run the google authentication setup, so you
#    may have to make a choice of using an existing auth, or logging in with
#    via web
#   it also auto runs devtools::load_all()
#   to load all the other functions from the project, which also loads the data
#  4. run the function validate_all() from the R console which reads all,
#     validation_problems <- capture.output(validate_all())

require(dplyr)
gdrive_setup()

### GLOBALS
csv_folder = '../L0'
dir.create(csv_folder, showWarnings = FALSE)
biomass_validation_file <- 'inst/rules/biomass_validation_rules.yaml'
env_validation_file <- 'inst/rules/env_validation_rules.yaml'
data(commassembly_rules_biomass_str)
data(commassembly_rules_env_str)


# sheet_data is one row of the URLS data frame, as a list, url is ..$url
read_and_report<- function(url, tab_name, spec.df, id=NA){
  read_data_sheet_save_warnings <- commruleR::errorSaver(read_data_sheet)
  data.df <- read_data_sheet_save_warnings(gurl = url,
                                           tab_name,
                                           spec.df)

  if("warnings" %in% names(data.df)) {
    print(data.df$warnings)
    read_error_message <- paste("reading warnings ", url, " tab_name:", tab_name )
    if (! is.na(id)) {
      read_error_message <- paste(id, read_error_message)
    }
    print(read_error_message)

    # get just the data so what's left can be validated
    data.df <- data.df[[1]]
  }

  return(data.df)
}


validation_report<- function(data.df, validation_file){
  confrontation<- validate_from_file(data.df, validation_file)
  validation_summary <- validate::summary(confrontation)
  if(sum(validation_summary$fails) == 0) {
    return(TRUE)
  } else {
    # print(validation_summary)
    fails <- dplyr::filter(validation_summary , fails > 0)
    print(fails)
    return(FALSE)
  }
}


save_csvs<- function(sheet_data, verbose = FALSE){

  if(verbose == TRUE) print(paste(sheet_data$id, sheet_data$url))

  url <- sheet_data$url

  #### ENV
  env.df <- read_and_report(url,
                            tab_name = 'env_data',
                            spec.df = commassembly_rules_env_str)
  if(!exists('env.df')) {
    print(paste("could not read sheet: "))
    return (c(NA, NA))
  }
  env_valid <- validation_report(env.df, env_validation_file)

  ## BIOMASS READ
  biomass.df <- read_and_report(url,
                                tab_name = 'biomass_data',
                                spec.df = commassembly_rules_biomass_str)
  if(!exists('biomass.df')) {
    print(paste("could not read sheet "))
    return (c(NA, NA))
  }
  # BIOMASS VALIDATION
  biomass_valid <- validation_report(biomass.df, biomass_validation_file)

  if(! (biomass_valid && env_valid)) {
    print(paste(sheet_data$id, sheet_data$url, " validated: biomass=", biomass_valid, " env=", env_valid ))
  }
  # SAVE
  id_new <- sheet_data$ID_new
  biomass_file_name <- file.path(csv_folder, paste0('biomass_', id_new, '.csv'))
  write.csv(biomass.df, biomass_file_name, row.names = FALSE)
  env_file_name <- file.path(csv_folder, paste0('env_', id_new, '.csv'))
  write.csv(env.df, env_file_name, row.names = FALSE)
  return(c(biomass_file_name, env_file_name))

}

validate_and_save_one<-function(id, urls.df = NULL, verbose = FALSE){
  if(is.null(urls.df)){
    doc_with_list_url <- Sys.getenv('TEST_ID_LIST_URL')
    id_column = 'ID_new'
    urls.df <- read_url_list(gurl = doc_with_list_url, id_column = "ID_new", url_column='url')
  }


  study_info <- as.list(urls.df[urls.df$id == id,])
  if(verbose ==TRUE) print(paste(study_info$id, study_info$url))

  tryCatch({
    file_names<- save_csvs(study_info)
    return(file_names)
  }, error=function(e) print(e))

}

#' read the list of urls, read, confirm column format, validate and
#' when using in development mode, make sure do run `devtools::load_all()`
#' to get all the commruleR functions loaded
#' save to CSV
validate_all<- function(urls.df=NULL, drive_email =NULL){
  if(!gsheet_auth_setup(drive_email)){
    warning("could not authenticate with google sheets api")
    return(False)
  }

  # list of URLS from google drive to a data sheet
  if(is.null(urls.df) || is.na(urls.df)){
    doc_with_list_url <- Sys.getenv('TEST_ID_LIST_URL')
    id_column = 'ID_new'
    urls.df <- read_url_list(gurl = doc_with_list_url, id_column = "ID_new", url_column='url')
    message(paste("URLs read from ", doc_with_list_url))
  }



  for(i in seq(1:nrow(urls.df))) {
    study_id = unlist(urls.df$id)[i]
    study_info = unlist(urls.df[i,])

    file_names <- validate_and_save_one(id = study_id, urls.df)
    if(NA %in% file_names) {
      print(paste("errors in id", urls.df$id[i]))
      print("---------------")
    }
  }
}

