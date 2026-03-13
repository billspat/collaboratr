# check google cloud api key configuration

google drive requires an 'api key' set in cloud project, which you can
copy from the cloud console. how that works is beyond the scope of this,
but is a 39-character alphanumber code. This function checks that the
key is in the environment, which can be set in Renviron. see help for
more details

## Usage

``` r
get_api_key()
```
