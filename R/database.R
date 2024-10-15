#' read in the table of google sheet URLs with id
#'
#' google sheet requires two column on for id one for the url for that id
#' the names of which can be anything but
#'
#' @returns dataframe with columns from google sheet with at least two columns 'id' and 'url' plus other columns in original sheet
#' @export
read_url_list<- function(gurl, id_column = 'id', url_column='url', drive_email = NULL){

  # create standardized id column named 'id' to make working with this table easier
  urls.df <- read_gsheet_by_url(gurl, sheet_id = 1,  has_description_line = FALSE, drive_email = drive_email)
  # standardize ID column
  if (! id_column %in% colnames(urls.df)) {
    warning(paste('sheet must have an id column and did not find id_column=', id_column,' in this sheets columns', colnames(id.df)))
    return(NA)
  }

  if (id_column != 'id'){
    # since id is not the standard 'id', create a duplicate column that has that name
    # this could be an issue if this table is very large
    id_col_number = which(colnames(urls.df) == id_column)

    urls.df[['id']] = urls.df[[id_column]]
  }

  # create standardized URL column named 'url'
  if (! url_column %in% colnames(urls.df)) {
    warning(paste('sheet must have a url column and did not find ur_column=', url_column,' in this sheets columns', colnames(id.df)))
    return(NA)
  }
  if (url_column !=  'url'){
    # since id is not the standard  'url', create a duplicate column that has that name
    # this could be an issue if this table is very large
    id_col_number = which(colnames(urls.df) == url_column)

    urls.df[['url']] = urls.df[[url_column]]
  }

  return( urls.df)

}

read_meta<- function(gurl, data_sheet_id, metadata_sheet_id, drive_email= NULL){
  data_df <- read_gsheet_by_url(gurl, sheet_id = data_sheet_id, has_description_line = TRUE, drive_email = drive_email)
  metadata_df <- read_gsheet_by_url(gurl, sheet_id = metadata_sheet_id, has_description_line = TRUE, drive_email = drive_email)

}

aggregate_database <- function(url_list_url, data_sheet_id, metadata_sheet_id, id_column = 'id', url_column = 'url', drive_email= NULL){
  urls.df <- read_url_list(gurl = url_list_url, id_column = id_column, url_column = url_column, drive_email = drive_email)

  for(df_row in rownames(urls.df)){
    gurl <- urls.df[df_row, url]
    data_df <- read_gsheet_by_url(gurl, sheet_id = data_sheet_id, has_description_line = TRUE, drive_email = drive_email)
    metadata_df <- read_gsheet_by_url(gurl, sheet_id = metadata_sheet_id, has_description_line = TRUE, drive_email = drive_email)

  }





}
