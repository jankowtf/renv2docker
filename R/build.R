#' Build into renv/local
#'
#' Build into directory `renv/local`
#'
#' @return
#' @export
#'
#' @examples
build_into_renv_local <- function() {
  usethis::use_build_ignore(c("data", "renv"))
  devtools::document()
  devtools::build(path = .env_dir_renv_local())
  # install.packages(paste0(package_name, ".tar.gz"), repos = NULL, type="source")
  # renv::install(list.files(pattern = paste0(package_name, ".*\\.tar\\.gz")))
}
