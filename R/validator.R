
#' read in data from a paper/study from all sheets
read_commrules_sheet<-function(sheeturl, drive_email=NULL){

  biomass_tab = 1
  env_tab = 2
  # try/catch
  cr_data <- list()
  cr_data$biomass <- read_gsheet_by_url(sheeturl, biomass_tab)
  cr_data$env <- read_gsheet_by_url(sheeturl, env_tab)

  return(cr_data)
}

