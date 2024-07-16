# gdrive.R
#
# a few functions to interact with Google drive files from R for our project, primarily
# for open CSV files when you don't have Google Drive Desktop installed (and Google shared drive
# mounted )
#
# Author: Pat Bills, Michigan State University, Spring 2024
# collaborators : see DESCRIPTION of this package
#
#
#
# these functions require the following packages to be installed
# install.packages( c( "googlesheets4", "googledrive")), which are 'suggested' for this package
#
# These functions also require a googlesheet and drive API created in the Google Cloud console

# To Use: then you must "require(googledrive)" which asks you to log-in
# to prevent that from happening when this sheet is sourced, it's wrapped into a function
# that gets called prior to running other functions

#' check google cloud api key configuration
#'
#' google drive requires an 'api key' set in  cloud project, which you can copy from the cloud console.
#' how that works is beyond the scope of this, but is a 39-character alphanumber code.  This function
#' checks that the key is in the environment, which can be set in Renviron.  see help for more details
get_api_key<-function(){

  k = Sys.getenv('PROJECT_API_KEY')
  if(!grep('^\\w{39}$', k, perl=TRUE) == 1)
     {stop("the PROJECT_API_KEY is either not set in .Renviron or is not a alpha-numeric length 39")}

  return(k)

}


get_drive_email <- function(drive_email = NULL){
  if( is.null(drive_email)){
    drive_email <- if(!is.null(drive_email)) drive_email else Sys.getenv('PROJECT_EMAIL')
  }

  if(drive_email==""){
    warning("no email provided to connect to drive.  please include the parameter or set one in .Renviron")

  }

  return( drive_email)
}

#' get a google drive 'client' for authentication from env file
#'
#' reads values from the enviroment for configurating a google drive client
#' for accesing gdrive file or gsheets data
#' @returns 'client' for use in drive_auth_configure or
gdrive_client_setup <- function(){
  drive_api_id_file <- Sys.getenv('DRIVE_API_ID_FILE')
  drive_api_id_name<- Sys.getenv('DRIVE_API_ID_NAME')
  if(!file.exists(drive_api_id_file)){
    stop("can't find ID file from Renviron DRIVE_API_ID_FILE, can't authenticate to google drive")
  }

  gdrive_client <- gargle::gargle_oauth_client_from_json(path=drive_api_id_file, name = drive_api_id_name)
  # setup both APIs
  googlesheets4::gs4_auth_configure(client = gdrive_client)
  googledrive::drive_auth_configure(client = gdrive_client)
  return(TRUE)
}


#' connect to your google drive account, required set-up for using the google drive packages
#'
#' this is wrapped in a function because it has the side effect of logging in, and useful for
#' the two functions to read data from sheets or CSVs.
#'
#' This setup is not needed for working with folders/datafiles connected to your computer
#' via Google Drive Desktop (Mac/Windows), only for reading files directly
#'
#' @return TRUE if the functions requiring the google R packages complete without error
#' @export
gdrive_setup <- function(drive_email=NULL, reset=FALSE){
  #TODO check if these are installed (since only 'suggested') and error if not
  require(googledrive)

  drive_email <- get_drive_email(drive_email)


  if(reset){
    googledrive::drive_deauth()
  }

  if(! googledrive::drive_has_token()){
    if(!gdrive_client_setup()){
      warning("can't setup google drive/sheets authentication client")
      return(FALSE)
    }
    googledrive::drive_auth(email = drive_email,scopes="drive.readonly")

    }

  return(TRUE)
}



#' setup authentication for reading google sheet
#'
#' this reads from the environment (or Renviron file) to get configuration details
#' for authenticating to a google sheets service.
#'
#' note that this is nearly identical to gdrive_setup but only for google sheets
#' google sheets has a different API and different permissions in the cloud console to read
#' @param drive_email
#' @returns True/False if the authentication/setup was successful
gsheet_auth_setup<-function(drive_email){

  # don't know if we also have to setup google drive
  #   if (! gdrive_setup(drive_email)){
  #   warning("Problem with google drive authentication setup")
  #   return(NULL)
  # }

  if(! googledrive::drive_has_token()) {

    drive_email = get_drive_email(drive_email)

    if(!gdrive_client_setup()){
      warning("can't setup google drive/sheets authentication client")
      return(FALSE)
    }

    googlesheets4::gs4_auth(email=drive_email, scopes="drive.readonly")

    if(! googlesheets4::gs4_has_token()) {
      warning("Problem with google sheets authentication setup")
      return(FALSE)

    }
    if(!gdrive_setup(drive_email)){
      warning("Problem: google sheets authenticated but google drive did not")
      return(FALSE)
    }
  }

  return( TRUE)


}

#' read data in a google sheet given the sheets URL
#'
#' Note This is only for google sheets, not CSVs or other data files.

#' requires Oauth and google cloud console setup
read_gsheet_by_url<-function(gurl, sheet_tab_number= 1, drive_email = NULL){

  if(!gsheet_auth_setup(drive_email)) {
    warning("no token for reading Google sheets.  Was there a problem with log-in?  Try gdrive_setup()")
    return( NULL)
  }

  sheet_dataframe = googlesheets4::read_sheet(googledrive::as_id(gurl), sheet = sheet_tab_number)
  return(sheet_dataframe)

}



#' WIP get time stamp for a particular gfile
#'
#' @param gfile a file object from google drive
#' @return timestamp value
#' @export
gfile_modified_time<-function(gfile){
  ts<- gfile$drive_resource[[1]]$modifiedTime
  return(ts)
}


#' download a CSV file from the project google shared drive and read into memory
#'
#' given a CSV filename, find it in our shared drive and read it in.  If there are multiple files
#' found with the same name on the share drive, throws a warning and reads only the first one
#' it finds  (which may not be the most recent one!   )
#'
#' This is not needed for working with folders/datafiles connected to your computer
#' via Google Drive Desktop (Mac/Windows), only for reading files directly.  If you don't have access
#' to the share drive it will not work
#'
#' @param filepath full name of the CSV file (e.g. myfile.csv ) with optional partial path.
#' @param shared_drive name of the shared drive to look in, defaults to the MSB project drive (2021)
#'
#' @return a data.frame as returned by read.csv, no row names.
#' @export
read_gcsv<-function(file_name, shared_drive=NULL, file_path=NULL){

  shared_drive <- if(is.null(shared_drive)) shared_drive else Sys.getenv('PROJECT_SHARE_DRIVE')
  # if( shared_drive == "") {
  #     warning("no share drive in the environment, please use the shared drive parameter to specify the share drive name")
  #     return( NULL)
  #   }
  # }

  file_path <- if(is.null(file_path)) file_path else Sys.getenv('PROJECT_SHARE_DRIVE_PATH')

  # load Google packages if not already, and log-in
  gdrive_setup()
  if(! googledrive::drive_has_token()) {
    warning("no token for reading from Google drive.  Was there a problem with log-in?  Please run googledrive::drive_auth()")
    return( NULL)
  }

  # retrieve file spec/info from Google drive
  full_file_path <- paste(file_name, file_path, sep = "/")
  gs_file<- googledrive::drive_get(path=full_file_path , shared_drive=shared_drive)

  # check if we found more than one file' not sure if this is the foolproof way to do it
  if( nrow(gs_file) > 1){
    warning("multiple files discovered, selecting the first one.  drive_get(filepath, team_drive = shared_drive)")
  }

  #TODO check file size before reading in and confirm large files
  local_file <- file.path(tempdir(), gs_file[1,]$name)

  local_file_infos <- googledrive::drive_download(gs_file[1,], path=local_file, overwrite = TRUE)

  csvdata<-read.csv(local_file_infos$local_path, row.names = NULL)
  return(csvdata)
}

#' test/example file
test_gdrive<- function(testcsvname, share){
  print("this will take a while... as it finds the file 2x (one to get info, one to read")
  some_data <- read_gcsv(filepath=testcsvname)
  summary(some_data)
  return(some_data)
}
