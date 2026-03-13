# setup authentication for reading google sheet

this reads from the environment (or Renviron file) to get configuration
details for authenticating to a google sheets service note that this is
nearly identical to gdrive_setup but only for google sheets google
sheets has a different API and different permissions in the cloud
console to read

## Usage

``` r
gsheet_auth_setup(drive_email = NULL)
```

## Arguments

- drive_email:

  your preferred email, can be read from environment, set
  get_drive_email

## Value

True/False if the authentication/setup was successful
