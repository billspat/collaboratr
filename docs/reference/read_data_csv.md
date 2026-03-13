# read in a CSV from L0 folder, using specification spec

reading in a CSV using readr package, but ensure the data still matches
a specification

## Usage

``` r
read_data_csv(csv_file_path, spec.df = NULL)
```

## Arguments

- csv_file_path:

  character path to csv file

- spec.df:

  optional data frame list of data specifications

## Value

data.frame, or NA if the file is not found or if there are validation
issues
