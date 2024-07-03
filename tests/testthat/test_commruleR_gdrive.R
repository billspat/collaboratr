#' test_commruleR_gdrive.R

test_that("tests work", {
  expect_true(TRUE)
})


test_that("can setup auth to google drive", {
  result = gdrive_setup()
  expect_true(result)
})

test_that("can download_csv_file", {
  test_drive_path <- 'CommAssemblyRULES/data/L0/L0_InProgress'
  test_drive_file <-'279'
  shared_drive = Sys.getenv('PROJECT_SHARE_DRIVE')
  result <-read_gcsv(file_name=test_drive_file, shared_drive=shared_drive, file_path=test_drive_path)
  expect_true(!is.null(result))
})
