# Function wrapper to capture errors and warnings for storing

errorSaver wraps functions to capture error and warning outputs that
would noramlly be emitted to the console can can't be saved. useful for
using in apply or loop, here used to collect the warnings issued by
readr functions which issue warnings to the console but we want to
collect those warnings If there are no errors and no warnings, the
regular function result is returned If there are warnings or errors,
returns a list with \$warn and \$err elements this method breaks down if
the result

## Usage

``` r
errorSaver(fun)
```

## Arguments

- fun:

  The function from which we'll capture errors and warnings

## Value

a wrapped

## References

<http://stackoverflow.com/questions/4948361/how-do-i-save-warnings-and-errors-as-output-from-a-function>

## Examples

``` r
log.errors <- errorSaver(log)
log.errors("a")
#> [[1]]
#> NULL
#> 
#> $warnings
#> NULL
#> 
#> $errors
#> [1] "non-numeric argument to mathematical function"
#> 
log.errors(1)
#> [1] 0
read_csv_with_warnings <- errorSaver(readr::read_csv)
```
