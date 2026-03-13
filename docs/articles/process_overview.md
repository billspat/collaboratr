# Google Sheet Validation Process Outline

``` r

library(collaboratR)
```

This package enables the use of Google Sheets as a collabrative data and
meta- data entry tool for researchers of different skill sets, automated
validation of the data using standarized rules, and to tracking all
changes to data using git

### Components

Workflow Overview:

- read metadata
  - schema (column definitions) from google sheets
  - list of data sheet URLs
  - validation rules (from Rdata file)
- read data files (from Google Sheets)
- validate
  - data format against schema
  - data values against rules
- report errors
- save all sheets as CSV and for commit to git
- combine to master list(s)

### Setup/Requirements

This code is written specifically to accommodate a multi-tab sheet setup
that is unique to a meta-analysis of plant competition experiments and
expects the sheets to have multiple tabs.  
1. Metadata in a google sheet

- list of all fields and field types
