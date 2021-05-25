# Test fixtures -----------------------------------------------------------

path_renv_local <- test_path("test_fixtures/renv/local")
path_renv_local %>% fs::dir_create()

test_that("Build into renv/local", {
  actual <- build_into_renv_local(path_renv_local)
  expected <-
      if (rlang::is_interactive()) {
        "tests/testthat/test_fixtures/renv/local/{pkgload::pkg_name()}_{pkgload::pkg_version()}.tar.gz" %>%
          stringr::str_glue() %>%
          as.character()
      } else {
        "test_fixtures/renv/local/{pkgload::pkg_name()}_{pkgload::pkg_version()}.tar.gz" %>%
          stringr::str_glue() %>%
          as.character()
      }

  expect_identical(actual, expected)
})
