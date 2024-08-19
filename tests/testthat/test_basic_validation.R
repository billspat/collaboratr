#' test_basic_validation.R

test_that("tests work", {
  expect_true(TRUE)
})


test_that("can read biomass", {
  # check this
  test_biomass_url<- 'https://docs.google.com/spreadsheets/d/1JVTRm1uQCrcOjXCULBYEgbW5oyd1S7SVGq6D1JpwCW4/edit?gid=0#gid=0'
  gdrive_setup()
  df <- read_gsheet_by_url(gurl = test_biomass_url, sheet_tab_number = 1, has_description_line = TRUE)
  expect_true(typeof(df)=='list')
  expect_true('ID_new' %in% names(df))

})


