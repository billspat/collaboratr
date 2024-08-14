#' test_commruleR_gdrive.R

test_that("tests work", {
  expect_true(TRUE)
})


test_that("can setup auth to google drive", {
  result = gdrive_setup()
  expect_true(result)
})

test_that("can get gs file spec from url", {
  test_url <- "https://docs.google.com/spreadsheets/d/1qccS4Y_UCJrrZdqy6lbPELJ8ZOM4mclR2vg4IWIXbPo/edit?gid=0#gid=0"
  result <- get_gsfile(file_name_or_url=test_url)
  expect_true(!is.null(result))
  # todo: use regex test, which I can find that returns the whole string
  expect_type(googledrive::as_id(result), "character")

  # check that the google drive id is just alpha number using str_extract output having same length as id
  file_id = googledrive::as_id(result)
  expect_equal(nchar(file_id), 44)
})

test_that("can get gs file spec", {
  test_drive_path <- 'CommAssemblyRULES'
  test_drive_file <-'Year Mapping'
  shared_drive = Sys.getenv('PROJECT_SHARE_DRIVE')
  result <- get_gsfile(file_name_or_url=test_drive_file, shared_drive=shared_drive, drive_path=test_drive_path)
  expect_true(!is.null(result))
  # todo: use regex test, which I can find that returns the whole string
  expect_type(googledrive::as_id(result), "character")

  # check that the google drive id is just alpha number using str_extract output having same length as id
  file_id = googledrive::as_id(result)
  rematch <- stringr::str_extract( file_id, stringr::regex('[:alnum:]*'))
  expect_equal(nchar(file_id), nchar(rematch))
})

test_that("can download_csv_file", {
  test_drive_path <- 'CommAssemblyRULES'
  test_drive_file <- 'Year Mapping'
  shared_drive = Sys.getenv('PROJECT_SHARE_DRIVE')
  result <-read_gcsv(file_name_or_url =test_drive_file, shared_drive=shared_drive, drive_path=test_drive_path)
  expect_true(!is.null(result))
})

