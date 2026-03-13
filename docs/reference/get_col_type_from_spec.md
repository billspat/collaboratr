# vector of types from column names, in order

csvs/sheets created to specs may not be in order of specification, but
we want to get the col types in order that the sheet is actually in This
get the colum types in the order the columns appear in the spreadsheet
that is read (in case columns are re-ordered) by checking one by one
requires the a spec data frame that must have columns named col_name and
col_type

## Usage

``` r
get_col_type_from_spec(col_name, spec)
```

## Arguments

- col_name:

  character, vector of column names from the data to look up the formats

- spec:

  data.frame of specification with columns 'col_name' to match, and
  'col_type

## Value

character vector of column types
