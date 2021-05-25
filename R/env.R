.env_package_name <- function() {
    "renv2docker"
}

#' Environment variable: package name
#'
#' @return [[character]] Package name
#' @importFrom pkgload pkg_name
#' @export
#'
#' @examples
#' env_package_name()
env_package_name <- function() {
    pkgload::pkg_name()
}

#' Environment variable: package version
#'
#' @return [[character]] Package version (as character to increase compatibilty)
#' @importFrom pkgload pkg_version
#' @export
#'
#' @examples
#' env_package_version()
env_package_version <- function() {
    pkgload::pkg_version() %>%
        as.character()
}

#' Environment variable: package maintainer
#'
#' @return
#' @importFrom pkgload pkg_version
#' @export
#'
#' @examples
#' env_package_maintainer()
env_package_maintainer <- function() {
    # usethis:::project_data() %>%
    usethis:::package_data() %>%
        purrr::pluck("Authors@R") %>%
        rlang::parse_expr() %>%
        rlang::eval_tidy() %>%
        as.character() %>%
        stringr::str_replace("<", "(") %>%
        stringr::str_replace(">", ")")
}

#' Environment variable: package port
#'
#' @param port [[integer]] Port. Defaults to `8000`
#'
#' @return [[integer]] Port
#' @importFrom pkgload pkg_version
#' @export
#'
#' @examples
#' env_package_port()
env_package_port <- function(
    port = 8000
) {
    port
}

#' Environment variable: dependency manager name
#'
#' @return [[character]] Package name with suffix `_deps`
#' @importFrom stringr str_c
#' @export
#'
#' @examples
#' env_dcm_name()
env_dcm_name <- function() {
    env_package_name() %>%
        stringr::str_c("_deps")
}

#' Environment variable: r version
#'
#' Relevant for cached build argument/environment variable for Docker.
#'
#' @return [[character]] R version (`{major}.{minor}.{patch}`)
#' @importFrom stringr str_c
#' @export
#'
#' @examples
#' env_r_version()
env_r_version <- function() {
    stringr::str_c(R.version$major, ".", R.version$minor) %>%
        as.character()
}

#' Environment variable: renv version
#'
#' @return [[character]] Version of `{renv}`.
#' @export
#'
#' @examples
#' env_renv_version()
env_renv_version <- function() {
    packageVersion("renv") %>%
        as.character()
}

# Write -------------------------------------------------------------------

#' Write environment variable to file
#'
#' @param value [[character]] Value of the env var.
#' @param dir [[character]] Path to directory that env var files should be
#'   written to. Defaults to root directory of your package/project (via
#'   [here::here()])
#' @param file_name [[character]] Optional file name. If none is provided then
#'   `.docker_env_{function_name}` is use with `function_name` being the name of
#'   the function that called this function (e.g. [env_package_name]).
#' @return [[character]] File path
#'
write_env_var <- function(
    value,
    dir = here::here(),
    file_name = character()
) {
    .Deprecated("Not really needed anymore, but keep as reference")

    # Compose file name in case it is not provided (default)
    if (!length(file_name)) {
        # Capture name of calling function
        var <- sys.call(-1)[[2]]

        # Compose file name
        file_name <- ".docker_env_{var}" %>%
            stringr::str_glue()
    }

    # Compose file path
    path <- dir %>%
        fs::path(file_name)

    # Write
    value %>% write(path)

    # Return
    path
}

#' Write environment variables to file
#'
#' @param dir [[character]] Path to directory that env var files should be
#'   written to
#'
#' @param dir [[character]] Path to directory that env var files should be
#'   written to. Defaults to root directory of your package/project (via
#'   [here::here()])
#' @return [[list]] List of path names
#' @export
#'
#' @examples
#' write_env_vars(dir = tempdir())
write_env_vars <- function(
    dir = here::here(),
    file_name = ".env"
) {
    # Compose definition structure for .env file
    env_vars_flat <- list(
        PACKAGE_NAME = env_package_name(),
        PACKAGE_VERSION = env_package_version(),
        PACKAGE_MAINTAINER = env_package_maintainer(),
        PACKAGE_PORT = env_package_port(),
        R_VERSION = env_r_version(),
        RENV_VERSION = env_renv_version(),
        DCM_NAME = env_dcm_name()
    ) %>%
        purrr::imap_chr(~"{.y}='{.x}'" %>% stringr::str_glue())

    # Write
    env_vars_flat %>%
        write(fs::path(dir, file_name))

    logger::log_success("Written environment variables to '{file_name}'")

    # Return
    env_vars_flat
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
#' .env_dir_renv()
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
#' .env_dir_renv_local()
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
#' .env_dir_renv_cache
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
#' .env_dir_renv_cache_docker()
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
#' .env_renv_activate()
.env_renv_activate <- function() {
    .env_dir_renv() %>%
        fs::path("activate.R")
}

#' Internal environment variable: renv lockfile
#'
#' Exists for single-source-of-truth encapsulation of internal settings for
#' `{renv}` lockfile
#'
#' @return
#'
#' @examples
#' .env_renv_lockfile()
.env_renv_lockfile <- function() {
    "renv.lock" %>%
        fs::path()
}

#' Internal environment variable: cached renv lockfile
#'
#' Exists for single-source-of-truth encapsulation of internal settings for
#' `{renv}` lockfile
#'
#' @return
#'
#' @examples
#' .env_renv_lockfile_cached()
.env_renv_lockfile_cached <- function() {
    "renv/{.env_renv_lockfile()}" %>%
        stringr::str_glue() %>%
        fs::path()
}

