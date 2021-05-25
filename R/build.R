#' Build into renv/local
#'
#' Build package into directory `renv/local`.
#'
#' @param dir [[character]] Path to `local` directory withing `renv`.
#' Defaults to `./renv/local`, but could be desirable to change (especially for
#' unit testing)
#'
#' @return [[character]] File path of .tar.gz file
#' @export
#'
#' @examples
#' build_into_renv_local()
build_into_renv_local <- function(
  dir = .env_dir_renv_local()
) {
  usethis::use_build_ignore(c("data", "renv"))
  devtools::document()
  devtools::build(path = dir)
  # install.packages(paste0(package_name, ".tar.gz"), repos = NULL, type="source")
  # renv::install(list.files(pattern = paste0(package_name, ".*\\.tar\\.gz")))
}
