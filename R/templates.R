#' Use template
#'
#' Motivated by [usethis::use_template], but needed to be liberated from
#' always using [usethis::proj_path].
#'
#' @param template
#' @param save_as
#' @param data
#' @param ignore
#' @param open
#' @param package
#'
#' @return
#' @export
#'
#' @examples
use_template <- function (
    template,
    save_as = template,
    data = list(),
    ignore = FALSE,
    open = FALSE,
    package = "usethis"
) {
    template_contents <- usethis:::render_template(
        template = template,
        data = data,
        package = package
    )
    new <- usethis::write_over(save_as, template_contents)
    if (ignore) {
        usethis::use_build_ignore(save_as)
    }
    if (open && new) {
        usethis::edit_file(proj_path(save_as))
    }
    invisible(new)
}

#' Use build template
#'
#' @param dir [[logical]] Path to directory where file should be created
#' @param open [[logical]]
#' - `TRUE`: create and open file
#' - `FALSE`: create but do not open file
#'
#' @return [[character]] Path to file that was created based on template
#' @import usethis
#' @import pkgload
#' @importFrom rlang is_interactive
#' @export
use_template_build <- function(
    dir = here::here(),
    open = rlang::is_interactive()
) {
    # File path to create
    template <- "build.R"
    path <- fs::path(dir, template)

    # Data to populate template with
    # data <- usethis:::project_data()
    data <- list()
    data$package <- pkgload::pkg_name()

    # Create from template
    use_template(
        template = template,
        save_as = path,
        data = data,
        ignore = usethis:::is_package(),
        open = open,
        package = data$package
    )

    invisible(path)
}

#' Use Dockerfile template
#'
#' @param dir [[character]] Path to directory where file should be created
#' @param r_script [[character]] File name of script within `inst/`
#' @param open [[logical]]
#' - `TRUE`: create and open file
#' - `FALSE`: create but do not open file
#'
#' @return [[character]] Path to file that was created based on template
#' @import usethis
#' @import pkgload
#' @importFrom rlang is_interactive
#' @export
use_template_dockerfile <- function(
    dir = here::here(),
    r_script = "main.R",
    open = rlang::is_interactive()
) {
    # File path to create
    template <- "Dockerfile"
    path <- fs::path(dir, template)

    # Data to populate template with
    data <- usethis:::project_data()
    names(data) <- names(data) %>% tolower()
    data$maintainer <- data$`authors@r` %>%
        rlang::parse_expr() %>%
        rlang::eval_tidy() %>%
        as.character() %>%
        stringr::str_replace("<", "(") %>%
        stringr::str_replace(">", ")") %>%
        shQuote()
    # data$r_version <- get_r_version()
    data$r_script <- r_script

    # Create from template
    use_template(
        template = template,
        save_as = path,
        data = data,
        ignore = usethis:::is_package(),
        open = open,
        package = data$package
    )

    invisible(path)
}

#' Use Dockerfile template (dependency manager)
#'
#' @param dir [[character]] Path to directory where file should be created
#' @param r_script [[character]] File name of script within `inst/`
#' @param open [[logical]]
#' - `TRUE`: create and open file
#' - `FALSE`: create but do not open file
#'
#' @return [[character]] Path to file that was created based on template
#' @import usethis
#' @import pkgload
#' @importFrom rlang is_interactive
#' @export
use_template_dockerfile_dep_manager <- function(
    dir = here::here(),
    r_script = "main.R",
    open = rlang::is_interactive()
) {
    # File path to create
    template <- "Dockerfile_dep_manager"
    path <- fs::path(dir, "renv/Dockerfile")
    path %>%
        fs::path_dir() %>%
        fs::dir_create()

    # Data to populate template with
    data <- usethis:::project_data()
    names(data) <- names(data) %>% tolower()
    data$maintainer <- data$`authors@r` %>%
        rlang::parse_expr() %>%
        rlang::eval_tidy() %>%
        as.character() %>%
        stringr::str_replace("<", "(") %>%
        stringr::str_replace(">", ")") %>%
        shQuote()
    # data$r_version <- get_r_version()

    # Create from template
    use_template(
        template = template,
        save_as = path,
        data = data,
        ignore = usethis:::is_package(),
        open = open,
        package = data$package
    )

    invisible(path)
}

#' Use docker-build template
#'
#' @param dir [[character]] Path to directory where file should be created
#' @param open [[logical]]
#' - `TRUE`: create and open file
#' - `FALSE`: create but do not open file
#'
#' @return [[character]] Path to file that was created based on template
#' @import usethis
#' @import pkgload
#' @importFrom rlang is_interactive
#' @export
use_template_docker_build <- function(
    dir = here::here(),
    open = rlang::is_interactive()
) {
    # File path to create
    template <- "docker_build.sh"
    path <- fs::path(dir, template)
    path %>%
        fs::path_dir() %>%
        fs::dir_create()

    # Create from template
    use_template(
        template = template,
        save_as = path,
        ignore = usethis:::is_package(),
        open = open,
        package = pkgload::pkg_name()
    )

    invisible(path)
}

#' Use docker run template
#'
#' @param dir [[character]] Path to directory where file should be created
#' @param open [[logical]]
#' - `TRUE`: create and open file
#' - `FALSE`: create but do not open file
#'
#' @return [[character]] Path to file that was created based on template
#' @import usethis
#' @import pkgload
#' @importFrom rlang is_interactive
#' @export
use_template_docker_run <- function(
    dir = here::here(),
    open = rlang::is_interactive()
) {
    # File path to create
    template <- "docker_run.sh"
    path <- fs::path(dir, template)
    path %>%
        fs::path_dir() %>%
        fs::dir_create()

    # Create from template
    use_template(
        template = template,
        save_as = path,
        ignore = usethis:::is_package(),
        open = open,
        package = pkgload::pkg_name()
    )

    invisible(path)
}

# Helpers -----------------------------------------------------------------

get_r_version <- function() {
    stringr::str_c(R.version$major, ".", R.version$minor)
}
