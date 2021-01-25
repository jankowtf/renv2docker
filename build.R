# Dependencies ------------------------------------------------------------

# library("magrittr")
library(renv2docker)

# Manage renv cache -------------------------------------------------------

# renv_cache <- here::here("renv/cache")
renv_ensure_cache_dir()

# renv_set_env_var_cache()
# Sys.getenv("RENV_PATHS_CACHE")

reinstall_deps <- as.logical(Sys.getenv("RENV_REINSTALL_DEPENDENCIES", FALSE))

# force_cache_update <- TRUE
force_cache_update <- FALSE

# Install dependencies ----------------------------------------------------

if (reinstall_deps) {
    source("install_dependencies.R")
}

# Persist environment variables for Docker --------------------------------

write_env_vars()

# Ignore dependencies -----------------------------------------------------

# {here} currently needed by {confx} and the others by {devtools} which is on
# the hit list
if (FALSE) {
    # renv::settings$ignored.packages(c(
    #   # "devtools",
    #   "here",
    #   "usethis",
    #   "roxygen2",
    #   "testthat"
    # ))
} else {
    renv::settings$ignored.packages(character())
}
# print(renv::settings$ignored.packages())

renv::settings$ignored.packages(env_package_name())

# Ensure renv/local directory exists and is clean -------------------------

renv_ensure_local_dir()

# Build -------------------------------------------------------------------

build_into_renv_local()

# Remove dev package ------------------------------------------------------

# renv_remove_dev_package()

# Create snapshot ---------------------------------------------------------

renv_snapshot()

# Manage cached {renv} manifest -------------------------------------------

renv_manage_cached_manifest()

renv_add_manifest_record()

# Preps for Docker --------------------------------------------------------

renv_ensure_cache_docker_dir()
