# connect to your google drive account, required set-up for using the google drive packages

this is wrapped in a function because it has the side effect of logging
in, and useful for the two functions to read data from sheets or CSVs.

## Usage

``` r
gdrive_setup(drive_email = NULL, reset = FALSE)
```

## Arguments

- drive_email:

  email to be used for google drive. Reads from env var, see
  get_drive_email

- reset:

  boolean whether to start over and re-authorize

## Value

TRUE if the functions requiring the google R packages complete without
error

## Details

This setup is not needed for working with folders/datafiles connected to
your computer via Google Drive Desktop (Mac/Windows), only for reading
files directly
