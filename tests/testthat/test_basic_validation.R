#' test_basic_validation.R

test_that("tests work", {
  expect_true(TRUE)
})


test_that("can read biomass", {
  # check this
  gdrive_setup()
  test_biomass_url<- 'https://docs.google.com/spreadsheets/d/1JVTRm1uQCrcOjXCULBYEgbW5oyd1S7SVGq6D1JpwCW4/edit?gid=0#gid=0'
  gdrive_setup()
  df <- read_commrules_sheet(test_biomass_url)
  expect_true(typeof(df)=='list')
  expect_true('ID_new' %in% names(df))

})


