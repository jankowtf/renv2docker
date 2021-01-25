test_that("Ensure local dir", {
  result <- renv_ensure_local_dir()

  target <- .env_dir_renv_local()

  expect_identical(result, target)
  expect_true(fs::dir_exists(target))
})

test_that("Ensure cache dir", {
  result <- renv_ensure_cache_dir()

  target <- .env_dir_renv_cache()

  expect_identical(result, target)
  expect_true(fs::dir_exists(target))
})

test_that("Ensure docker cache dir", {
  result <- renv_ensure_cache_docker_dir()

  target <- .env_dir_renv_cache_docker()

  expect_identical(result, target)
  expect_true(fs::dir_exists(target))
})

test_that("Digest primary lockfile", {
  result <- renv_digest_primary_lockfile()

  expect_type(result, "character")
  expect_identical(nchar(result), 32L)
})

test_that("Digest cached lockfile", {
  result <- renv_digest_cached_lockfile()

  expect_type(result, "character")
  expect_identical(nchar(result), 32L)
})

test_that("Manage cached lockfile", {
  result <- renv_manage_cached_lockfile()

  target <- .env_renv_lockfile_cached()

  expect_identical(result, target)
  expect_true(fs::file_exists(target %>%
      here::here()))
})
