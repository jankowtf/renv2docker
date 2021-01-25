#' Environment variable value: package name
#'
#' @return
#' @importFrom pkgload pkg_name
#' @export
#'
#' @examples
#' env_package_name()
env_package_name <- function() {
  pkgload::pkg_name()
}

#' Environment variable value: package version
#'
#' @return
#' @importFrom pkgload pkg_version
#' @export
#'
#' @examples
#' env_package_version()
env_package_version <- function() {
  pkgload::pkg_version() %>%
    as.character()
}

#' Environment variable value: dependency manager name
#'
#' @return
#' @importFrom stringr str_c
#' @export
#'
#' @examples
#' env_dependency_manager_name()
env_dependency_manager_name <- function() {
  env_package_name() %>%
    stringr::str_c("_deps")
}

#' Environment variable value: r version
#'
#' @return
#' @importFrom stringr str_c
#' @export
#'
#' @examples
#' env_r_version()
env_r_version <- function() {
  stringr::str_c(R.version$major, ".", R.version$minor) %>%
    as.character()
}

#' Environment variable value: renv version
#'
#' @return
#' @export
#'
#' @examples
#' env_renv_version()
env_renv_version <- function() {
  packageVersion("renv") %>%
    as.character()
}

# Internal ----------------------------------------------------------------

#' Internal environment variable: `{renv}` dir
#'
#' Single-source-of-truth encapsulation of internal settings for
#' `{renv}` directory.
#'
#' @return
#'
#' @examples
.env_dir_renv <- function() {
  "renv" %>%
    fs::path()
}

#' Internal environment variable: `{renv}` dir: local
#'
#' Single-source-of-truth encapsulation of internal settings for
#' `{renv}` directory where tar.gz of the current package is persisted
#'
#' @return
#'
#' @examples
.env_dir_renv_local <- function() {
  .env_dir_renv() %>%
    fs::path("local")
}

#' Internal environment variable: `{renv}` dir: cache
#'
#' Single-source-of-truth encapsulation of internal settings for
#' `{renv}` dir for ache
#'
#' @return
#'
#' @examples
.env_dir_renv_cache <- function() {
  .env_dir_renv() %>%
    fs::path("cache")
}

#' Internal environment variable: `{renv}` dir: cache_docker
#'
#' Single-source-of-truth encapsulation of internal settings for
#' `{renv}` dir for docker cache
#'
#' @return
#'
#' @examples
.env_dir_renv_cache_docker <- function() {
  .env_dir_renv() %>%
    fs::path("cache_docker")
}

#' Internal environment variable: renv/activate
#'
#' Exists for single-source-of-truth encapsulation internal settings for
#' `{renv}` activation script
#'
#' @return
#'
#' @examples
.env_renv_activate <- function() {
  .env_dir_renv() %>%
    fs::path("activate.R")
}

#' Internal environment variable: renv manifest
#'
#' Exists for single-source-of-truth encapsulation of internal settings for
#' `{renv}` manifest
#'
#' @return
#'
#' @examples
.env_renv_manifest <- function() {
  "renv.lock" %>%
    fs::path()
}

#' Internal environment variable: cached renv manifest
#'
#' Exists for single-source-of-truth encapsulation of internal settings for
#' `{renv}` manifest
#'
#' @return
#'
#' @examples
.env_renv_manifest_cached <- function() {
  "renv/{.env_renv_manifest()}" %>%
    stringr::str_glue() %>%
    fs::path()
}
