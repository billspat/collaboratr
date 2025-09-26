


# read_google_sheet_with_spec<-function(gurl, has_description_row = FALSE, )
# testfile =  "/Users/billspat/tmp/df.csv"
# row_1 = strsplit(readLines(testfile , 1), ',')[[1]]
# df2 = readr::read_csv(file = "/Users/billspat/tmp/df.csv", col_names = spec.df$col_name, col_types = paste0(substr(spec.df$col_type, 1, 1), collapse = ''))


#' Function wrapper to capture errors and warnings for storing
#'
#' errorSaver wraps functions to capture error and warning outputs that would
#' noramlly be emitted to the console can can't be saved.   useful for using
#' in apply or loop, here used to collect the warnings issued by readr
#' functions which issue warnings to the console but we want to collect those
#' warnings
#' If there are no errors and no warnings, the regular function result is returned
#' If there are warnings or errors, returns a list with $warn and $err elements
#' this method breaks down if the result
#' @export
#' @param fun The function from which we'll capture errors and warnings
#' @return a wrapped
#' @references
#' \url{http://stackoverflow.com/questions/4948361/how-do-i-save-warnings-and-errors-as-output-from-a-function}
#' @examples
#' log.errors <- errorSaver(log)
#' log.errors("a")
#' log.errors(1)
#' read_csv_with_warnings <- errorSaver(readr::read_csv)
errorSaver <- function(fun)
  function(...) {
    warn <- err <- NULL
    fun_results <- withCallingHandlers(
      tryCatch(fun(...), error=function(e) {
        err <<- conditionMessage(e)
        NULL
      }), warning=function(w) {
        warn <<- append(warn, conditionMessage(w))
        invokeRestart("muffleWarning")
      })
    if(is.character(warn) || is.character(err))
      list(fun_results, warnings=warn, errors=err)
    else
      fun_results
}


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
type_converter_fun<- function(type_code) {
    if (type_code == 'character' || type_code == 'c'){
      return(readr::parse_character())
      # return(as.character)
    }
    if (type_code == 'integer' || type_code == 'i'){
      return()
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


type_converter_fun<- function(type_code) {
  if (type_code == 'character' || type_code == 'c'){
    return(readr::parse_character())
    # return(as.character)
  }
  if (type_code == 'integer' || type_code == 'i'){
    return()
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
#' convert a type name to a readr convert code
#'
#' readr uses convert codes - see vignette("readr")
#' this function allows for named types and will convert those to the 1-letter
#' codes used by reader
#' @param type_code single letter or string of type
#' @returns character single letter code
type_code_to_readr_code<- function(type_code) {
  if (type_code == 'character'){
    return('c')
  }
  if (toupper(type_code) == 'INTEGER' ){
    return('i')
  }

  if (toupper(type_code) == 'FACTOR' ){
    return('f')
  }

  if (toupper(type_code) == 'DOUBLE' || toupper(type_code) == 'NUMERIC'){
    return('d')
  }
  if (type_code == 'Date' || type_code == 'D' ){
    return('D')
  }

  return(type_code)
}

#' convert our specification format to something useable by readr::read_csv
#'
#' @param spec.df dataframe with columns 'col_name' and 'data_str'
#' @returns list of col names and type abbreviations, per read_csv() docs
#' @export
spec_to_readr_col_types<- function(spec.df){
  spec_list = list()
  for (row in 1:nrow(spec.df)) {

    spec_list[[spec.df$col_name[row] ]] <- type_code_to_readr_code(spec.df$data_str[row])
  }
  return(spec_list)
}



#' given a URL and params, read, validate and save a CSV
#'
#' filename <- read_and_save(url, sheet_id = 'biomass_data', spec.df = commassembly_rules_biomass_str))

read_validate_and_save<- function(url, tab_name, spec.df, csv_folder = '../L0'){

  dir.create(csv_folder, showWarnings = FALSE)

  tryCatch({
    data.df <- read_data_sheet(url,
                               tab_name = tab_name,
                               spec.df = spec.df)

    }, error=function(e) {
       print(e)
       return( NA)
    }
  )

  id_new = env.df$ID_new[1]
  biomass_file_name <- file.path(csv_folder, paste0('biomass_', id_new, '.csv'))
  write.csv(biomass.df, biomass_file_name, row.names = FALSE)
  env_file_name <- file.path(csv_folder, paste0('env_', id_new, '.csv'))
  write.csv(env.df, env_file_name, row.names = FALSE)

  return(c(biomass_file_name, env_file_name))

}
