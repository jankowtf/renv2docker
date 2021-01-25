restart_rstudio <- function (message = NULL)
{
    if (!in_rstudio(proj_get())) {
        return(FALSE)
    }
    if (!is_interactive()) {
        return(FALSE)
    }
    if (!is.null(message)) {
        ui_todo(message)
    }
    if (!rstudioapi::hasFun("openProject")) {
        return(FALSE)
    }
    if (ui_nope("Restart now?")) {
        return(FALSE)
    }
    rstudioapi::openProject(proj_get())
}
