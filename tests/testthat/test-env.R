# Package name ------------------------------------------------------------

test_that("Package name", {
  result <- env_package_name()

  target <- pkgload::pkg_name()

  expect_identical(result, target)
})

# Package version ---------------------------------------------------------

test_that("Package version", {
  result <- env_package_version()

  target <- pkgload::pkg_version() %>% as.character()

  expect_identical(result, target)
})

# Dependency manager name -------------------------------------------------

test_that("Dependency manager name", {
  result <- env_dependency_manager_name()

  target <- "{env_package_name()}_deps" %>%
    stringr::str_glue() %>%
    as.character()

  expect_identical(result, target)
})

# R version ---------------------------------------------------------------

test_that("R version", {
  result <- env_r_version()

  target <- stringr::str_c(R.version$major, ".", R.version$minor) %>%
    as.character()

  expect_identical(result, target)
})

# {renv} version ----------------------------------------------------------

test_that("{renv} version", {
  result <- env_renv_version()

  target <- packageVersion("renv") %>%
    as.character()

  expect_identical(result, target)
})

# Write -------------------------------------------------------------------

test_that("Write env vars to file", {
  result <- write_env_vars()
  expectation <- list(
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
  expect_identical(result, expectation)

  # Check for file existance
  files_exist <- result %>% purrr::map_lgl(fs::file_exists)
  expect_true(all(files_exist))
})

test_that("Write env vars to file: alternative dir", {
  result <- write_env_vars(dir = test_path("test_fixtures"))
  expectation <- list(
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
  expect_identical(result, expectation)

  # Check for file existance
  files_exist <- result %>% purrr::map_lgl(fs::file_exists)
  expect_true(all(files_exist))
})

# Internal ----------------------------------------------------------------

test_that(".Env: renv dir", {
  result <- .env_dir_renv()

  target <- "renv" %>%
    fs::path()

  expect_identical(result, target)
})

test_that(".Env: renv dir for package build", {
  result <- .env_dir_renv_local()

  target <- "renv/local" %>%
    fs::path()

  expect_identical(result, target)
})

test_that(".Env: renv dir for docker cache", {
  result <- .env_dir_renv_cache()

  target <- "renv/cache" %>%
    fs::path()

  expect_identical(result, target)
})

test_that(".Env: renv dir for docker cache", {
  result <- .env_dir_renv_cache_docker()

  target <- "renv/cache_docker" %>%
    fs::path()

  expect_identical(result, target)
})

test_that(".Env: renv activation script", {
  result <- .env_renv_activate()

  target <- "renv/activate.R" %>%
    fs::path()

  expect_identical(result, target)
})

test_that(".Env: renv manifest", {
  result <- .env_renv_manifest()

  target <- "renv.lock" %>%
    fs::path()

  expect_identical(result, target)
})

test_that(".Env: cached renv manifest", {
  result <- .env_renv_manifest_cached()

  target <- "renv/renv.lock" %>%
    fs::path()

  expect_identical(result, target)
})
