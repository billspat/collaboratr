# convert our specification format to something useable by readr::read_csv

convert our specification format to something useable by readr::read_csv

## Usage

``` r
spec_to_readr_col_types(spec.df)
```

## Arguments

- spec.df:

  dataframe with columns 'col_name' and 'data_str'

## Value

list of col names and type abbreviations, per read_csv() docs
