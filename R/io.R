#' Write environment variable to file
#'
#' @param env_var [[character]] Value of the env var.
#' @param dir [[character]] Path to directory that env var files should be
#'   written to. Defaults to root directory of your package/project (via
#'   [here::here()])
#' @param file_name [[character]] Optional file name. If none is provided then
#'   `.docker_env_{function_name}` is use with `function_name` being the name of
#'   the function that called this function (e.g. [env_package_name]).
#' @return [[character]] File path
#' @export
#'
#' @examples
write_env_var <- function(
  env_var,
  dir = here::here(),
  file_name = character()
) {
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
  env_var %>% write(path)

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
#' @export
#'
#' @examples
#' write_env_vars(dir = tempdir())
write_env_vars <- function(
  dir = here::here()
) {
  # Compose
  package_name <- env_package_name()
  package_version <- env_package_version()
  package_maintainer <- env_package_maintainer()
  package_port <- env_package_port()

  r_version <- env_r_version()
  renv_version <- env_renv_version()

  dependency_manager_name <- env_dependency_manager_name()

  # Trying to set env vars directly
  # Doesn't work as they are not visible for other bash processes
  # Sys.setenv(R_PACKAGE_NAME = package_name)

  # Writes
  ret <- list()
  ret$package_name <- package_name %>% write_env_var(dir = dir)
  ret$package_version <- package_version %>% write_env_var(dir = dir)
  ret$package_maintainer <- package_maintainer %>% write_env_var(dir = dir)
  ret$package_port <- package_port %>% write_env_var(dir = dir)

  ret$dependency_manager_name <- dependency_manager_name %>% write_env_var(dir = dir)

  ret$r_version <- r_version %>% write_env_var(dir = dir)
  ret$renv_version <- renv_version %>% write_env_var(dir = dir)

  ret
}
