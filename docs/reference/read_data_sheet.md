# read in google sheet for formatted for specific project, similar to how the readr package works for read_csv with a spec sheet data sheet features

- allows you to skip top row(s) of data - allows for sheets that have
  non-data rows that are descriptive

- numeric columns can have numeric strings and those will be converted
  to NAs, e.g. can indicate "NA" in numeric cells

- requires a spec sheet that uses names per `type_converter_fun()`

read in google sheet for formatted for specific project, similar to how
the readr package works for read_csv with a spec sheet data sheet
features

- allows you to skip top row(s) of data - allows for sheets that have
  non-data rows that are descriptive

- numeric columns can have numeric strings and those will be converted
  to NAs, e.g. can indicate "NA" in numeric cells

- requires a spec sheet that uses names per
  [`type_converter_fun()`](https://github.com/IBEEM-MSU/collaboratR/reference/type_converter_fun.md)

## Usage

``` r
read_data_sheet(
  gurl,
  tab_name,
  spec.df,
  rows_to_skip = 1,
  use_readr = TRUE,
  quiet = TRUE
)
```

## Arguments

- gurl:

  google sheet url or ID per googlesheets package

- tab_name:

  sheet tab name or number, forward to sheet param in
  googlesheets4::read_sheet

- spec.df:

  data.frame that is the specification, must have columns col_name and
  data_str

- rows_to_skip:

  integer default 1, number of rows to skip, not including col names.
  some sheets have non-data or documentation in first rows set to 0 to
  not skip any rows

- use_readr:

  logical default TRUE, use readr::type_convert() to validate

## Value

data.frame or NA if there is a problem
