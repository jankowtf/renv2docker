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

test_that("Dependency manager name", {
  actual <- env_dependency_manager_name()

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
  expected <- list(
    package_name = structure(
      "/media/janko/Shared/Code/R/Packages/renv2docker/.docker_env_package_name",
      class = c("fs_path",
        "character")
    ),
    package_version = structure(
      "/media/janko/Shared/Code/R/Packages/renv2docker/.docker_env_package_version",
      class = c("fs_path",
        "character")
    ),
    package_maintainer = structure(
      "/media/janko/Shared/Code/R/Packages/renv2docker/.docker_env_package_maintainer",
      class = c("fs_path",
        "character")
    ),
    package_port = structure(
      "/media/janko/Shared/Code/R/Packages/renv2docker/.docker_env_package_port",
      class = c("fs_path",
        "character")
    ),
    dependency_manager_name = structure(
      "/media/janko/Shared/Code/R/Packages/renv2docker/.docker_env_dependency_manager_name",
      class = c("fs_path",
        "character")
    ),
    r_version = structure(
      "/media/janko/Shared/Code/R/Packages/renv2docker/.docker_env_r_version",
      class = c("fs_path",
        "character")
    ),
    renv_version = structure(
      "/media/janko/Shared/Code/R/Packages/renv2docker/.docker_env_renv_version",
      class = c("fs_path",
        "character")
    )
  )
  expect_identical(actual, expected)

  # Check for file existance
  files_exist <- actual %>% purrr::map_lgl(fs::file_exists)
  expect_true(all(files_exist))
})

test_that("Write env vars to file: alternative dir", {
  actual <- write_env_vars(dir = test_path("test_fixtures"))
  expected <- list(
    package_name = structure(
      r"({test_path("test_fixtures")}/.docker_env_package_name)" %>%
        stringr::str_glue(),
      class = c("fs_path",
        "character")
    ),
    package_version = structure(
      r"({test_path("test_fixtures")}/.docker_env_package_version)" %>%
        stringr::str_glue(),
      class = c("fs_path",
        "character")
    ),
    package_maintainer = structure(
      r"({test_path("test_fixtures")}/.docker_env_package_maintainer)" %>%
        stringr::str_glue(),
      class = c("fs_path",
        "character")
    ),
    package_port = structure(
      r"({test_path("test_fixtures")}/.docker_env_package_port)" %>%
        stringr::str_glue(),
      class = c("fs_path",
        "character")
    ),
    dependency_manager_name = structure(
      r"({test_path("test_fixtures")}/.docker_env_dependency_manager_name)" %>%
        stringr::str_glue(),
      class = c("fs_path",
        "character")
    ),
    r_version = structure(
      r"({test_path("test_fixtures")}/.docker_env_r_version)" %>%
        stringr::str_glue(),
      class = c("fs_path",
        "character")
    ),
    renv_version = structure(
      r"({test_path("test_fixtures")}/.docker_env_renv_version)" %>%
        stringr::str_glue(),
      class = c("fs_path",
        "character")
    )
  )
  expect_identical(actual, expected)

  # Check for file existance
  files_exist <- actual %>% purrr::map_lgl(fs::file_exists)
  expect_true(all(files_exist))
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
