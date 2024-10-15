

test_that("can read the list of doc URLs using read gsheet", {
  doc_with_list_url <- Sys.getenv('TEST_ID_LIST_URL')
  if(doc_with_list_url == ""){
    warning("you must set the environment variable TEST_ID_LIST_URL to a sheet with a list of urls for this to work")

  } else {
    gdrive_setup()
    df <- read_gsheet_by_url(gurl = doc_with_list_url, sheet_id = 1, has_description_line = FALSE)
    expect_true(typeof(df)=='list')
    expect_true('ID_new' %in% names(df))
  }
})


test_that("can read the list of doc URLs", {
  # this uses the current project's id name
  id_column <- "ID_new"
  doc_with_list_url <- Sys.getenv('TEST_ID_LIST_URL')
  if(doc_with_list_url == ""){
    warning("you must set the environment variable TEST_ID_LIST_URL to a sheet with a list of urls for this to work")

  } else {
    urls.df <- read_url_list(gurl = doc_with_list_url, id_column = id_column, url_column='url')

    expect_true(typeof(urls.df)=='list')
    expect_true(id_column %in% names(urls.df))
    expect_gt(length(urls.df), 0)

    # the function above ensures these two columns are in the results
    expect_true('url' %in% names(urls.df))
    expect_true('id' %in% names(urls.df))

  }
})


test_that("can use a URL in the list of doc URLs ", {
  id_column <- "ID_new"
  doc_with_list_url <- Sys.getenv('TEST_ID_LIST_URL')
  if(doc_with_list_url == ""){
    warning("you must set the environment variable TEST_ID_LIST_URL to a sheet with a list of urls for this to work")

  } else {
    urls.df <- read_url_list(gurl = doc_with_list_url, id_column = id_column, url_column='url')
    data.df <- read_gsheet_by_url(gurl = urls.df$url[1], sheet_id = 1, has_description_line = TRUE)
    expect_true(typeof(data.df)=='list')
    expect_true(id_column %in% names(data.df))
    first_id_in_datasheet <- data.df[[id_column]][1]
    id_from_url_list <-  urls.df$id[1]
    expect_equal(first_id_in_datasheet, id_from_url_list)
  }
}
)
