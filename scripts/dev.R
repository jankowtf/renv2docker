# Dependencies ------------------------------------------------------------

# --- Dev

renv::install("rappster/renvx")
renv::install("pkgdown")

# --- Prod

usethis::use_package("magrittr")
usethis::use_package("renv")
usethis::use_package("stringr")
usethis::use_package("devtools")
usethis::use_package("here")
renv::install("pkgload")
usethis::use_package("pkgload")
renv::install("logger")
usethis::use_package("logger")

# Configure ---------------------------------------------------------------

usethis::use_pkgdown()
pkgdown::build_site()
usethis::use_code_of_conduct()
usethis::use_pipe()

# Tests -------------------------------------------------------------------

usethis::use_test("build")
usethis::use_test("env")
usethis::use_test("ensure")
usethis::use_test("renv")
usethis::use_test("templates")

# Vignettes ---------------------------------------------------------------

usethis::use_vignette("dev")
usethis::use_vignette("env_vars")
