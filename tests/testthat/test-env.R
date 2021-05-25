# Package name ------------------------------------------------------------

test_that("Package name", {
  actual <- env_package_name()

  expected <- pkgload::pkg_name()

  expect_identical(actual, expected)
})

# Package version ---------------------------------------------------------

test_that("Package version", {
  actual <- env_package_version()
  expected <- pkgload::pkg_version() %>% as.character()
  expect_identical(actual, expected)
})

# Package maintainer ------------------------------------------------------

test_that("Package maintainer", {
  actual <- env_package_maintainer()
  expected <- "Janko Thyson (janko.thyson@rappster.io) [aut, cre]"
  expect_identical(actual, expected)
})

# Package port ------------------------------------------------------------

test_that("Package port", {
  actual <- env_package_port()
  expected <- 8000
  expect_identical(actual, expected)
})


# Dependency manager name -------------------------------------------------

test_that("DCM name", {
  actual <- env_dcm_name()

  expected <- "{env_package_name()}_deps" %>%
    stringr::str_glue() %>%
    as.character()

  expect_identical(actual, expected)
})

# R version ---------------------------------------------------------------

test_that("R version", {
  actual <- env_r_version()

  expected <- stringr::str_c(R.version$major, ".", R.version$minor) %>%
    as.character()

  expect_identical(actual, expected)
})

# {renv} version ----------------------------------------------------------

test_that("{renv} version", {
  actual <- env_renv_version()

  expected <- packageVersion("renv") %>%
    as.character()

  expect_identical(actual, expected)
})

# Write -------------------------------------------------------------------

test_that("Write env vars to file", {
  actual <- write_env_vars()
  expected <- c(
    PACKAGE_NAME = "PACKAGE_NAME=renv2docker",
    PACKAGE_VERSION = "PACKAGE_VERSION=0.0.0.9005",
    PACKAGE_MAINTAINER = "PACKAGE_MAINTAINER=Janko Thyson (janko.thyson@rappster.io) [aut, cre]",
    PACKAGE_PORT = "PACKAGE_PORT=8000",
    R_VERSION = "R_VERSION=4.0.5",
    RENV_VERSION = "RENV_VERSION=0.12.5",
    DCM_NAME = "DCM_NAME=renv2docker_deps"
  )
  expect_identical(names(actual), names(expected))

  # Check for file existance
  expect_true(fs::file_exists(here::here(".env")))
})

test_that("Write env vars to file: alternative dir", {
  actual <- write_env_vars(dir = test_path("test_fixtures"))
  expected <- c(
    PACKAGE_NAME = "PACKAGE_NAME=renv2docker",
    PACKAGE_VERSION = "PACKAGE_VERSION=0.0.0.9005",
    PACKAGE_MAINTAINER = "PACKAGE_MAINTAINER=Janko Thyson (janko.thyson@rappster.io) [aut, cre]",
    PACKAGE_PORT = "PACKAGE_PORT=8000",
    R_VERSION = "R_VERSION=4.0.5",
    RENV_VERSION = "RENV_VERSION=0.12.5",
    DCM_NAME = "DCM_NAME=renv2docker_deps"
  )
  expect_identical(names(actual), names(expected))

  # Check for file existance
  expect_true(fs::file_exists(test_path("test_fixtures/.env")))
})

# Internal ----------------------------------------------------------------

test_that(".Env: renv dir", {
  actual <- .env_dir_renv()

  expected <- "renv" %>%
    fs::path()

  expect_identical(actual, expected)
})

test_that(".Env: renv dir for package build", {
  actual <- .env_dir_renv_local()

  expected <- "renv/local" %>%
    fs::path()

  expect_identical(actual, expected)
})

test_that(".Env: renv dir for docker cache", {
  actual <- .env_dir_renv_cache()

  expected <- "renv/cache" %>%
    fs::path()

  expect_identical(actual, expected)
})

test_that(".Env: renv dir for docker cache", {
  actual <- .env_dir_renv_cache_docker()

  expected <- "renv/cache_docker" %>%
    fs::path()

  expect_identical(actual, expected)
})

test_that(".Env: renv activation script", {
  actual <- .env_renv_activate()

  expected <- "renv/activate.R" %>%
    fs::path()

  expect_identical(actual, expected)
})

test_that(".Env: renv lockfile", {
  actual <- .env_renv_lockfile()

  expected <- "renv.lock" %>%
    fs::path()

  expect_identical(actual, expected)
})

test_that(".Env: cached renv lockfile", {
  actual <- .env_renv_lockfile_cached()

  expected <- "renv/renv.lock" %>%
    fs::path()

  expect_identical(actual, expected)
})
