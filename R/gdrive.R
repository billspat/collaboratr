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
#' @param drive_email email to be used for google drive.  Reads from env var, see get_drive_email
#' @param reset boolean whether to start over and re-authorize
#' @returns TRUE if the functions requiring the google R packages complete without error
#' @export
gdrive_setup <- function(drive_email=NULL, reset=FALSE){
  #TODO check if these are installed (since only 'suggested') and error if not

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
#' for authenticating to a google sheets service
#' note that this is nearly identical to gdrive_setup but only for google sheets
#' google sheets has a different API and different permissions in the cloud console to read

#' @param drive_email your preferred email, can be read from environment, set get_drive_email
#' @returns True/False if the authentication/setup was successful
#' @export
gsheet_auth_setup<-function(drive_email= NULL){

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


#' get a google drive file object given path and share drive
#'
#' given a google filepath , find it in our shared drive and read it in.  If there are multiple files
#' found with the same name on the share drive, throws a warning and reads only the first one
#' it finds  (which may not be the most recent one!   )
#'
#' This is not needed for working with folders/datafiles connected to your computer
#' via Google Drive Desktop (Mac/Windows), only for reading files directly from google drive.
#' If you don't have permission to access the share drive it will not work
#'
#' @param filepath full name of the file (e.g. myfile.csv ), which could include sub-folder (myfiles/myfile.csv) OR google drive URL
#' @param shared_drive optional name of the shared drive to look in, will read from the environment 'PROJECT_SHARE_DRIVE' ignored if URL is sent
#' @param drive_path optional standard path for project files, will read from environment 'PROJECT_SHARE_DRIVE_PATH'; ignored if URL is sent
#'
#' @return a gsfile object from google drive library, useable to read from other gdrive/gsheet functions
get_gsfile<-function(file_name_or_url, shared_drive=NULL, drive_path=NULL,drive_email=NULL){

  # load Google packages if not already, and log-in
  gdrive_setup(drive_email = drive_email)

  if(! googledrive::drive_has_token()) {
    warning("no token for reading from Google drive.  Was there a problem with log-in?  Please run googledrive::drive_auth()")
    return( NULL)
  }

  if(grepl('^https', file_name_or_url)){
    # first param is a url, so ignore all the others and just get the gsfile object
    gs_file<- googledrive::drive_get(file_name_or_url)
  } else {
    # it's a filename, not a url, check the other params
    shared_drive <- if(!is.null(shared_drive)) shared_drive else Sys.getenv('PROJECT_SHARE_DRIVE')
    # if( shared_drive == "") {
    #     warning("no share drive in the environment, please use the shared drive parameter to specify the share drive name")
    #     return( NULL)
    #   }
    # }

    drive_path <- if(!is.null(drive_path)) drive_path else Sys.getenv('PROJECT_SHARE_DRIVE_PATH')

    # retrieve file spec/info from Google drive
    full_file_path <- paste(drive_path, file_name_or_url, sep = "/")
    gs_file<- googledrive::drive_get(path=full_file_path , shared_drive=shared_drive)
  }

  return(gs_file)

}

#' read data in a google sheet from a URL and tab number
#'
#' Note This is only for google sheets, not CSVs or other data files.
#' this can read either type of data sheet (e.g. either tab) and returns th
#' To remove the 2nd "description" row, it downloads as CSV, removes the line,
#' and reads back in
#' This is a generic function, and does not use a specification file, see
#' read_data_sheet() below for that.
#'
#' requires Oauth and google cloud console setup
#' @param gurl url of a google sheet (and only a google sheet, not doc)
#' @param sheet_id optional the name or number of the tab (1, 2), defaults to 1, see read_sheet() fn
#' @param has_description_line does the sheet have row 2 as description of data, if TRUE (default), remove it
#' @param drive_email optional drive email, required if you have not already logged in or don't have it set in Env.  See gdrive_setup()
#' @returns data frame with contents of the tab
#' @export
read_gsheet_by_url<-function(gurl, sheet_id= 1, has_description_line = TRUE, drive_email = NULL){

  gs_file <- get_gsfile(gurl)

  # check if we found more than one file' not sure if this is the foolproof way to do it
  if( nrow(gs_file) > 1){
    warning("multiple files discovered, can't read from URL")
    return(NA)
  }

  #TODO check file size before reading in and confirm large files

  if(!gsheet_auth_setup(drive_email)) {
    warning("no token for reading Google sheets.  Was there a problem with log-in?  Try gdrive_setup()")
    return( NULL)
  }

  # to allow for column re-ordering, get the names from the sheet directly, rather than data dictionary

  if(has_description_line == TRUE){
    # the
    # read the sheet just to get the column names
    temp_dataframe <- googlesheets4::read_sheet(googledrive::as_id(gurl), sheet = sheet_id)
    col_names <- names(temp_dataframe)
    rm(temp_dataframe)
    # read in but skip header and row 2 with text description
    # this df has no col names but will most likley have the correct types
    df <- googlesheets4::read_sheet(googledrive::as_id(gurl), sheet = sheet_id, col_names = FALSE, skip=2)
    names(df)<- col_names

  } else {
    # no description row , just read it in
    df<- googlesheets4::read_sheet(googledrive::as_id(gurl), sheet = sheet_id)
  }

  #TODO transform numeric columns

  return(df)

}


#' read in google sheet for formatted for specific project, similar to how the
#' readr package works for read_csv with a spec sheet
#'  data sheet features
#'  - allows you to skip top row(s) of data  - allows for sheets that have
#'  non-data rows that are descriptive
#'  - numeric columns can have numeric strings and those will be converted to
#'    NAs, e.g. can indicate "NA" in numeric cells
#'  - requires a spec sheet that uses names per `type_converter_fun()`
#'
#' @param gurl google sheet url or ID per googlesheets package
#' @param tab_name sheet tab name or number, forward to sheet param in  googlesheets4::read_sheet
#' @param spec.df data.frame that is the specification, must have columns col_name and data_str
#' @param rows_to_skip integer default 1, number of rows to skip, not including
#'        col names.  some sheets have non-data or documentation in first rows
#'        set to 0 to not skip any rows
#' @param use_readr logical default TRUE, use readr::type_convert() to validate
#' @returns data.frame or NA if there is a problem
#' @export
read_data_sheet<- function(gurl, tab_name, spec.df, rows_to_skip = 1, use_readr=TRUE) {

  # read in the sheet but make the whole thing character to deal with special features of this project

  file_name <- googlesheets4::gs4_get(gurl)$name
  df <- googlesheets4::read_sheet(gurl, sheet = tab_name, col_types="c")

  # ditch the first row which is always text instructions for this particular project
  # remaining row/cols are all character
  df <- df[-1 * rows_to_skip,]

  # check col names against spec$col_name, do not allow deviations
  erroneous_col_names <- setdiff(names(df), spec.df$col_name)
  missing_col_names <- setdiff(spec.df$col_name, names(df))

  if(length(missing_col_names)>0 || length(erroneous_col_names)>0){
    if(length(erroneous_col_names)>0){ warning(paste(file_name, tab_name, "has erroneous column names:", erroneous_col_names))}
    if(length(missing_col_names)>0){ warning(paste(file_name, tab_name, "has missing columns:", missing_col_names))}

    return(NA)
  }

  if(use_readr==TRUE){
    # use the this function from reader to convert an all-character data frame
    # using a spec.  The huge advantage is that it detects "NA" in numeric
    # columns automatically
    df <- readr::type_convert(df,
                              col_types = spec_to_readr_col_types(spec.df),
                              na = c("", "NA")
    )
    conversion_issues<- readr::problems(df)
    if (nrow(conversion_issues) > 0){
      warning_message = paste(file_name, ": type validation issues with sheet ", gurl, " tab ",tab_name)
      warning(warning_message)
      warning(conversion_issues)
      return( NA)
    }

  } else {
    # non-readr manual method, before I discovered the awesome readr::type_convert()
    # get the data types in the same order as the sheet by mapping the names to data types using the spec
    col_types <- get_col_type_from_spec(names(df), spec.df)

    # internal function for running the conversion on the data frame, column by column
    for(col_name in names(df))
    {
      # get col type of this column from the spec
      col_type <- spec.df[spec.df$col_name == col_name, ]$data_str
      # if the col type is zero length, means the colname was NOT In the spec,
      if (length(col_type) == 0){
        warning(paste("column not found in specification ", col_name, " ... not converting"))

      } else {

        # the type_converter_fun returns a FUNCTION not data
        convert_function <- type_converter_fun(col_type)
        # convert it but dont' bother the user with all the NA conversion
        df[[col_name]] <- convert_function(df[[col_name]])
      }
    }
  }

  return(df)

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


#' remove line 2 from a csv file, used by data-entry for column directions/description.
#'
#' this will read all lines of a test file (which can take a long time/memory for a long file),
#' remove some of the lines by number and write those to disk.   If no new_file_path param
#' is sent, will overwrite the original file which will be lost
#' it will write a file with standard POSIX (linux/mac) line endings for now
#' @param local_file_path path to text file on your disk, relative or absolute
#' @param line_numbers default 2, 1 number or a vector, range of numbers to exclude (2:5)
#' @param new_file_path optional new name to write to, by default will use the local_file_path and overwrite
remove_comment_line<-function(local_file_path, line_numbers = 2, new_file_path = NULL){
  # set param
  new_file_path = if(!is.null(new_file_path)) new_file_path else local_file_path
  filelines = readr::read_lines(local_file_path)
  filelines <- filelines[-(line_numbers)]
  readr::write_lines(filelines, file=new_file_path)
  return(new_file_path)

}

#' download a CSV file from the project google shared drive and read into memory
#'
#' NOTE this can import gsheet as CSV, but only the first tab.  Use read_gsheet_by_url() for multi-tab sheets
#' Reads either CSV file or gsheet doc from a shared drive and reads it in as data frame.  If there are multiple files
#' found with the same name on the share drive, throws a warning and reads only the first one
#' it finds  (which may not be the most recent one!   )
#' This is not needed for working with folders/datafiles connected to your computer
#' via Google Drive Desktop (Mac/Windows), only for reading files directly the Internet via URL.  Requires access
#' to a share drive
#'
#' @param filepath full name of the CSV file (e.g. myfile.csv ) with optional partial path.
#' @param shared_drive name of the shared drive to look in, default NULL passed to get_gsfile which which reads path from environment (see get_gsfile)
#' @param drive_path common project path to use, optional, passed to get_gsfile which reads from environment (see get_gsfile)
#' @param has_comment_line =TRUE, does the google sheet have comments/directions on line 2 that needs to be stripped
#' @returns a data.frame as returned by read.csv, no row names.
#' @export
read_gcsv<-function( file_name_or_url, shared_drive=NULL, drive_path=NULL, has_comment_line = TRUE){

  gs_file <- get_gsfile(file_name_or_url, shared_drive, drive_path)

  # check if we found more than one file' not sure if this is the foolproof way to do it
  if( nrow(gs_file) > 1){
    warning("multiple files discovered, selecting the first one.  drive_get(filepath, team_drive = shared_drive)")
  }

  #TODO check file size before reading in and confirm large files
  local_file <- file.path(tempdir(), gs_file[1,]$name)

  local_file_infos <- googledrive::drive_download(gs_file, path=local_file, type="csv", overwrite = TRUE)

  if(has_comment_line == TRUE){
    local_file_path <- remove_comment_line(local_file_path= local_file_infos$local_path, line_numbers = 2)
  } else {
    local_file_path <- local_file_infos$local_path
  }

  csvdata<-readr::read_csv(file = local_file_path)  # (local_file_path, header = TRUE, row.names = NULL)
  return(csvdata)
}

