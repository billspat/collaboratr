# flexible character to date converter

try to convert a character to date using one of two delimiters ('/' or
'-') and start with international data format first (d/m/Y), but if that
fails try sci date format (Y-m-d) and finally US format. Value can be
'optional' in that if it's blank or not a date, NA is return

## Usage

``` r
# S3 method for class 'flexible'
as.Date(x, ...)
```

## Arguments

- x:

  character to be converted to date, or empty string

## Value

Date or NA if x is blank, using as.Date function with 'tryFormats'
option
