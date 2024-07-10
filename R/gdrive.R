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
  require(googlesheets4)
  require(googledrive)

  drive_email <- get_drive_email(drive_email)
  drive_api_key <- get_api_key()
  drive_api_id_file <- Sys.getenv('PROJECT_AUTH_FILE')
  drive_api_id_name='ibeem-commruleR'

  if(!file.exists(drive_id_file)){
    stop("can't find ID file from Renviron PROJECT_AUTH_FILE")
  }

  if(reset){
    googledrive::drive_deauth()
  }

  if(! googledrive::drive_has_token()){
    googledrive::drive_auth_configure(path=drive_api_id_file, api_key = drive_api_key)
    googledrive::drive_auth(email = drive_email,scopes="drive.readonly")

    }

  return(TRUE)
}


#' read in google sheet into memory using our shared drive
#'
#' reads the first sheet only, and the whole sheet.  Attemtps to load Google packages and log-in if necessary. In
#' the case there are two sheets with the same name, returns the first one it finds (not ideal! )
#'
#' Note This is only for google sheets, not CSVs or other data files.  It assumes the 'share drive' is
#' is available in the environment
#'
#' @param gsheet_name  required file name of the gsheet you need
#' @return data frame as returned by read.csv, or NULL if there is an issue
read_gsheet<- function(gsheet_name, shared_drive, verbose="FALSE"){

  # assuming the user wants to load google sheets package and log-in if she wants to read from it
  if(!gdrive_setup()){
    warning("there was a problem when setting up google drive authentication, can't open sheet")
    return(False)
  }

  if(! sheets_has_token()) {
    warning("no token for reading from Google drive.  Was there a problem with log-in?  Try gdrive_setup()")
    return( NULL)
  }

  if(verbose){
    print(paste("searching for ", gsheet_name))
  }


  gs_file<- drive_get(gsheet_name, team_drive = shared_drive)

  if (!single_file(gs_file)){
    warning("multiple files discovered, selecting the first one on the list!")
    gs_file <- gs_file[1,]
  }

  if(verbose){
    print(paste("reading data from ", gs_file$path))
  }

  gs_file<- gs_file[1,] # get the first one in case there are duplicates

  gs_data <- read_sheet(gs_file)
  ### how to read the data from read_sheet

  return(gs_data)

}

read_gsheet_url<-function(gurl){
  ginfo<-googledrive::drive_get(gurl)
  if('id' %in% names(ginfo)){
    read_gsheet()
  }

}

read_gsheet_id<-function(gid){
  f <- googledrive::drive_get(id=ginfo$id)

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
#' download a CSV from the project shared drive and read into memory
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
