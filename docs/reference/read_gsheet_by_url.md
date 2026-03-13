# read data in a google sheet from a URL and tab number

Note This is only for google sheets, not CSVs or other data files. this
can read either type of data sheet (e.g. either tab) and returns th To
remove the 2nd "description" row, it downloads as CSV, removes the line,
and reads back in This is a generic function, and does not use a
specification file, see read_data_sheet() below for that.

## Usage

``` r
read_gsheet_by_url(
  gurl,
  sheet_id = 1,
  has_description_line = TRUE,
  drive_email = NULL
)
```

## Arguments

- gurl:

  url of a google sheet (and only a google sheet, not doc)

- sheet_id:

  optional the name or number of the tab (1, 2), defaults to 1, see
  read_sheet() fn

- has_description_line:

  does the sheet have row 2 as description of data, if TRUE (default),
  remove it

- drive_email:

  optional drive email, required if you have not already logged in or
  don't have it set in Env. See gdrive_setup()

## Value

data frame with contents of the tab

## Details

requires Oauth and google cloud console setup
