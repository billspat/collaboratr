


# read_google_sheet_with_spec<-function(gurl, has_description_row = FALSE, )
# testfile =  "/Users/billspat/tmp/df.csv"
# row_1 = strsplit(readLines(testfile , 1), ',')[[1]]
# df2 = readr::read_csv(file = "/Users/billspat/tmp/df.csv", col_names = spec.df$col_name, col_types = paste0(substr(spec.df$col_type, 1, 1), collapse = ''))

#' vector of types from column names, in order
#'
#' csvs/sheets created to specs may not be in order of specification, but we want to get the col types in order that the sheet is actually in
#' This get the colum types in the order the columns appear in the spreadsheet that is read (in case columns are re-ordered) by checking one by one
#' requires the a spec data frame that must have columns named col_name and col_type
#' @param col_name character, vector of column names from the data to look up the formats
#' @param spec data.frame of specification with columns 'col_name' to match, and 'col_type
#' @returns character vector of column types
#' @export
get_col_type_from_spec <-Vectorize(
    function(col_name, spec) { return( spec[spec$col_name == col_name, ]$data_str)},
  'col_name')


#' flexible character to date converter
#'
#' try to convert a character to date using one of two delimiters ('/' or '-') and
#' start with international data format first (d/m/Y), but if that fails try sci date format (Y-m-d)
#' and finally US format.  Value can be 'optional' in that if it's blank or not a date, NA is return
#' @param x character to be converted to date, or empty string
#' @returns Date or NA if x is blank, using as.Date function with 'tryFormats' option
#' @export
as.Date.flexible <- function(x, ...){
  return(
    as.Date(x, tryFormats = c("%d/%m/%Y", "%d-%m-%YYY", "%Y-%m-%d", "%Y/%m/%d", "%m-%d-%Y", "%m/%d/%Y"),
          optional = TRUE, ...)
  )
}

#'code to conversion function mapping
#'
#' given a character code, return the conversion function to use on a value.
#' This is useful for spreadsheets/csvs that don't adapt well to conversion (even with formats specific)
#' and hence manual converting from character is needed
#' Yes this is probably a re-make of what's in read.csv or read_csv but those weren't amenable to a specific
#' use case
#' @param type_code character value indicating type, one of character, integer, factor, double, numeric, Date(capital D) or first letter
#' @returns one of the converter function as.integer... etc.  For Dates, return custom as.Date.flexible function defined above
#' @export
type_converter_fun<-
  function(type_code) {
    if (type_code == 'character' || type_code == 'c'){
      return(as.character)
    }
    if (type_code == 'integer' || type_code == 'i'){
      return(as.integer)
    }
    if (type_code == 'factor' || type_code == 'f'){
      return(as.factor)
    }
    if (type_code == 'double' || type_code == 'd' || type_code == 'n' || type_code == 'numeric'){
      return(as.numeric)
    }
    if (type_code == 'Date' || type_code == 'D' ){
      return(as.Date.flexible)
    }

    return(as.character)
}


#' read in google sheet for formatted for specific project
#'  data sheet features
#'  - has a 2nd row that is all text that needs to be removed
#'  - has the string "NA" in some cells that should be numeric only
#'  - since it's google some cols should be factors but that's not a thing google can do
#'  - date is not in standard scientific format
#' @param gurl google sheet url or ID per googlesheets package
#' @param sheet sheet tab name or number, forward to sheet param in  googlesheets4::read_sheet
#' @param spec data.frame that is the specification, must have columns col_name and data_str
#' @returns data.frame or NA if there is a problem
#' @export
read_commassemblyrules_sheet<- function(gurl, sheet, spec.df) {

  # read in the sheet but make the whole thing character to deal with special features of this project
  df <- googlesheets4::read_sheet(gurl, sheet = sheet, col_types="c")

  # ditch the first row which is always text instructions for this particular project
  # remaining row/cols are all character
  df <- df[-1,]

  # check col names against spec$col_name, do not allow deviations
  erroneous_col_names <- setdiff(names(df), spec.df$col_name)
  missing_col_names <- setdiff(spec.df$col_name, names(df))

  if(length(missing_col_names)>0 || length(erroneous_col_names)>0){
    if(length(erroneous_col_names)>0){ warning("sheet has erroneous column names", erroneous_col_names)}
    if(length(missing_col_names)>0){ warning("sheet has missing columns", missing_col_names)}

    return(NA)
  }

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

  return(df)

}

