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

test_that("Digest primary manifest", {
  result <- renv_digest_primary_manifest()

  expect_type(result, "character")
  expect_identical(nchar(result), 32L)
})

test_that("Digest cached manifest", {
  result <- renv_digest_cached_manifest()

  expect_type(result, "character")
  expect_identical(nchar(result), 32L)
})

test_that("Manage cached manifest", {
  result <- renv_manage_cached_manifest()

  target <- .env_renv_manifest_cached()

  expect_identical(result, target)
  expect_true(fs::file_exists(target %>%
      here::here()))
})
