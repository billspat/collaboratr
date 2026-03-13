# code to conversion function mapping

given a character code, return the conversion function to use on a
value. This is useful for spreadsheets/csvs that don't adapt well to
conversion (even with formats specific) and hence manual converting from
character is needed Yes this is probably a re-make of what's in read.csv
or read_csv but those weren't amenable to a specific use case

## Usage

``` r
type_converter_fun(type_code)
```

## Arguments

- type_code:

  character value indicating type, one of character, integer, factor,
  double, numeric, Date(capital D) or first letter

## Value

one of the converter function as.integer... etc. For Dates, return
custom as.Date.flexible function defined above
