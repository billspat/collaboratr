# read in the table of google sheet URLs with id

google sheet requires two column on for id one for the url for that id
the names of which can be anything but

## Usage

``` r
read_url_list(gurl, id_column = "id", url_column = "url", drive_email = NULL)
```

## Value

dataframe with columns from google sheet with at least two columns 'id'
and 'url' plus other columns in original sheet
