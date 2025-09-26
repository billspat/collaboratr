
<!-- README.md is generated from README.Rmd. Please edit that file -->

# collaboratR

### [MSU IBEEM](https://ibeem.msu.edu) commRULES project

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/collaboratR)](https://CRAN.R-project.org/package=collaboratR)
<!-- badges: end -->

*This is very early version under heavy development.*

This R package is part of 3 repositories that support the data entry,
validation and accumulation of a meta-analysis for the commRULES
project.

1.  commRULES data: version controlled data collection for tracking
    provenance using git, this is the L0 and L1 layers in the EDI
    framework
2.  collaboratR: commRULES data management code for L0 and L0-\>L1 layer
    in EDI framework
3.  commRULES-analysis: R code for reproducible data analysis , L1-\>L2
    layers in EDI framework

## Installation

This package uses [renv](https://rstudio.github.io/renv/) to manage the
packages you need to install, which creates an `renv.lock` file for you.

- install RENV: this can go into your R environment used for all
  packages, so fire up R with now project select and
  `install.packages('renv')`
- clone this repository into a [new Rstudio
  project](https://docs.posit.co/ide/user/ide/guide/code/projects.html)
  and open it
- inside the Rstudio project in the R console, `renv::restore()`
