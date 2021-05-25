
<!-- README.md is generated from README.Rmd. Please edit that file -->

# renv2docker

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/renv2docker)](https://CRAN.R-project.org/package=renv2docker)

<!-- badges: end -->

Project-specific cache of `{renv}` dependencies in Docker workflows

## Motivation

Past me:

1.  I wanted to use `{renv}` in combination with Docker and didn’t yet
    know how to mount my local [`{renv}`
    cache](https://rstudio.github.io/renv/articles/renv.html#cache-1),
    so the build process took **much** longer than I was willing to wait
    ;-)

2.  This also happened at a time before
    [rocker](https://hub.docker.com/u/rocker) switched to Ubuntu as the
    underlying Linux OS (Thanks to [Eric
    Nantz](https://twitter.com/thercast?lang=en) for pointing that out
    in your [podcast](https://github.com/rpodcast/r_dev_projects)!).

    Before that (AFAIU and AFAIR), it could happen that the compilation
    process slightly differed between Ubuntu and Debian(?). So even
    though you might have properly mounted your local [`{renv}`
    cache](https://rstudio.github.io/renv/articles/renv.html#cache-1) so
    it was available at build time, the resulting builds might have been
    incompatible with your local Linux OS.

    To be honest, I’m not sure how much of this still holds/is necessary
    after the switch to Ubuntu, but I nevertheless liked the idea of
    having an `{renv}` cache that is completely project-specific, so I
    continued building this package out.

    \[**TODO: Investigate the rocker history, etc. so I don’t tell
    incorrect stuff here** ;-)\]

So I wanted to have a faster build experience and came up with this
two-step approach:

**STEP 1**

Build an image that handles all of my package dependencies.

It only builds the dependencies once or when it has to (that is whenever
my `renv.lock` is updated) and caches them back to a subdirectory within
my local package directory (`./renv/cache_docker` \[TODO: or was it
`./renv/cache` –&gt; review this\]) for future builds.

I called this image the **D**ependency **C**ache **M**anager (**DCM**).

**STEP 2**

Build the actual image

This image get access to the locally persisted `{renv}` cache from the
previous step as well as `./renv/local` (the place where your package’s
`.tar.gz` file is built to when you use the `build.R`; see below).

It calls `renv::restore()` which uses the cache and restores your
package by installing it from source.

## Installation

``` r
remotes::install_github("rappster/renv2docker")
```

## Usage

``` r
library(renv2docker)
```

1.  Create the necessary environment variables for Docker

``` r
write_env_vars()
#> ✓ Setting active project to '/Users/jankothyson/Code2/R/Packages/renv2docker'
#> SUCCESS [2021-05-25 08:28:46] Written environment variables to '.env'
#>                                                            PACKAGE_NAME 
#>                                              "PACKAGE_NAME=renv2docker" 
#>                                                         PACKAGE_VERSION 
#>                                            "PACKAGE_VERSION=0.0.0.9005" 
#>                                                      PACKAGE_MAINTAINER 
#> "PACKAGE_MAINTAINER=Janko Thyson (janko.thyson@rappster.io) [aut, cre]" 
#>                                                            PACKAGE_PORT 
#>                                                     "PACKAGE_PORT=8000" 
#>                                                               R_VERSION 
#>                                                       "R_VERSION=4.0.5" 
#>                                                            RENV_VERSION 
#>                                                   "RENV_VERSION=0.12.5" 
#>                                                                DCM_NAME 
#>                                             "DCM_NAME=renv2docker_deps"
```

Technically, they are mostly used as `ARG`s instead of `ENV`s, but at
least for `PACKAGE_PORT` it would make sense to pass it on as e `ENV`.
Still learning about the nitty-gritty details ;-) See [Docker ARG, ENV
and .env - a Complete
Guide](https://vsupalov.com/docker-arg-env-variable-guide/) for more
details on this

1.  Generate `./Dockerfile` and `./renv/Dockerfile`

``` r
dockerfile <- use_template_dockerfile(open = FALSE)
#> ✓ Adding '^/Users/jankothyson/Code2/R/Packages/renv2docker/Dockerfile$' to '.Rbuildignore'
#> ℹ Created /Users/jankothyson/Code2/R/Packages/renv2docker/Dockerfile

readLines(dockerfile) %>% cat(sep = "\n")
#> # References
#> # Overall: https://cran.r-project.org/web/packages/renv/vignettes/docker.html
#> # Handling local sources: https://rstudio.github.io/renv/articles/local-sources.html
#> # Ignoring dev dependencies: https://rstudio.github.io/renv/articles/faq.html
#> # ARG for FROM: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
#> 
#> ARG  R_VERSION
#> FROM rocker/r-ver:$R_VERSION
#> 
#> ARG PACKAGE_NAME
#> ARG PACKAGE_VERSION
#> ARG PACKAGE_MAINTAINER
#> 
#> LABEL version=$PACKAGE_VERSION
#> LABEL maintainer=$PACKAGE_MAINTAINER
#> 
#> # Install Linux libs ----------
#> RUN apt-get update && \
#>   apt-get autoremove && \
#>   apt-get autoclean && \
#>   apt-get install \
#>   -y \
#>   --force-yes \
#>   -f \
#>   libsasl2-dev \
#>   libssl-dev \
#>   libcurl4 \
#>   libcurl4-openssl-dev \
#>   libxml2-dev \
#>   libsodium-dev \
#>   libz-dev \
#>   zlib1g-dev
#> 
#> # Copy dependency cache ----------
#> #RUN echo $(ls -a -1)
#> RUN mkdir -p /root/.local/share/renv
#> COPY renv/cache_docker/ /root/.local/share/renv
#> RUN echo $(ls -a -1 /root/.local/share/renv)
#> 
#> # Copy service components ----------
#> WORKDIR /service
#> RUN mkdir -p /service/logs
#> COPY renv.lock renv.lock
#> COPY renv/local renv/local
#> COPY renv/activate.R  renv/activate.R
#> 
#> COPY DESCRIPTION_OUTER DESCRIPTION
#> COPY inst/main.R main.R
#> # COPY .Rprofile .Rprofile
#> 
#> # Restore dependencies from cache ----------
#> RUN R \
#>   -e 'options("repos" = "https://packagemana¸ger.rstudio.com/all/__linux__/focal/latest")' \
#>   -e 'source("renv/activate.R")' \
#>   -e 'Sys.setenv(RENV_PATHS_LOCAL="renv/local")' \
#>   -e 'renv::restore()'
#> 
#> # Serve microservice via API ----------
#> CMD Rscript 'main.R'
```

``` r
dockerfile <- use_template_dockerfile_dcm(open = FALSE)
#> ✓ Adding '^/Users/jankothyson/Code2/R/Packages/renv2docker/renv/Dockerfile$' to '.Rbuildignore'
#> ℹ Created /Users/jankothyson/Code2/R/Packages/renv2docker/renv/Dockerfile

readLines(dockerfile) %>% cat(sep = "\n")
#> # References
#> # Overall: https://cran.r-project.org/web/packages/renv/vignettes/docker.html
#> # Handling local sources: https://rstudio.github.io/renv/articles/local-sources.html
#> # Ignoring dev dependencies: https://rstudio.github.io/renv/articles/faq.html
#> 
#> ARG  R_VERSION=4.0.3
#> 
#> FROM rocker/r-ver:${R_VERSION}
#> 
#> ARG PACKAGE_MANAGER="janko.thyson@rappster.io"
#> ARG PACKAGE_NAME
#> ARG PACKAGE_VERSION
#> ARG RENV_VERSION
#> 
#> RUN echo "PACKAGE_MANAGER: $PACKAGE_MANAGER"
#> RUN echo "PACKAGE_NAME: $PACKAGE_NAME"
#> RUN echo "PACKAGE_VERSION: $PACKAGE_VERSION"
#> RUN echo "R_VERSION: $R_VERSION"
#> RUN echo "RENV_VERSION: $RENV_VERSION"
#> 
#> LABEL version=$PACKAGE_VERSION
#> LABEL maintainer='Janko Thyson (janko.thyson@rappster.io) [aut, cre]'
#> 
#> RUN R \
#>     -e 'options("repos" = "https://packagemanager.rstudio.com/all/__linux__/focal/latest")' \
#>     -e 'install.packages("remotes")' \
#>     -e 'renv_package <- paste0("rstudio/renv@", Sys.getenv("RENV_VERSION"))' \
#>     -e 'remotes::install_github(renv_package)'
#> 
#> # Copy required components for cache management ----------
#> WORKDIR /dcm
#> COPY renv.lock renv.lock
#> 
#> # Install Linux libs ----------
#> RUN apt-get update && \
#>   apt-get autoremove && \
#>   apt-get autoclean && \
#>   apt-get install \
#>   -y \
#>   --force-yes \
#>   -f libsasl2-dev \
#>   libssl-dev \
#>   libcurl4 \
#>   libcurl4-openssl-dev \
#>   libxml2-dev \
#>   libsodium-dev \
#>   libgit2-dev \
#>   zlib1g-dev \
#>   libz-dev
#> 
#> # Restore dependencies ----------
#> #RUN R -e 'renv::consent(provided = TRUE)'
#> 
#> # Build actual cache files ----------
#> CMD R --no-save \
#>     -e 'renv::consent(provided = TRUE)' \
#>     -e 'renv::activate()' \
#>     -e 'renv::restore()'
```

1.  Generate `build.R`

This template ensures that your package is built into `./renv/local` and
that all workflow requirements of `renv2docker` are met regarding the
caching of package dependency builds.

``` r
build_r <- use_template_build(open = FALSE)
#> ✓ Leaving 'build.R' unchanged
#> ✓ Adding '^/Users/jankothyson/Code2/R/Packages/renv2docker/build\\.R$' to '.Rbuildignore'
#> ℹ Created /Users/jankothyson/Code2/R/Packages/renv2docker/build.R

readLines(build_r) %>% cat(sep = "\n")
#> # Dependencies ------------------------------------------------------------
#> 
#> devtools::load_all(here::here())
#> 
#> # Manage renv cache -------------------------------------------------------
#> 
#> # renv_cache <- here::here("renv/cache")
#> renv_ensure_cache_dir()
#> 
#> # renv_set_env_var_cache()
#> # Sys.getenv("RENV_PATHS_CACHE")
#> 
#> reinstall_deps <- as.logical(Sys.getenv("RENV_REINSTALL_DEPENDENCIES", FALSE))
#> 
#> # force_cache_update <- TRUE
#> force_cache_update <- FALSE
#> 
#> # Install dependencies ----------------------------------------------------
#> 
#> if (reinstall_deps) {
#>     source("install_dependencies.R")
#> }
#> 
#> # Persist environment variables for Docker --------------------------------
#> 
#> write_env_vars()
#> 
#> # Ignore dependencies -----------------------------------------------------
#> 
#> # {here} currently needed by {confx} and the others by {devtools} which is on
#> # the hit list
#> if (FALSE) {
#>     # renv::settings$ignored.packages(c(
#>     #   # "devtools",
#>     #   "here",
#>     #   "usethis",
#>     #   "roxygen2",
#>     #   "testthat"
#>     # ))
#> } else {
#>     renv::settings$ignored.packages(character())
#> }
#> # print(renv::settings$ignored.packages())
#> 
#> renv::settings$ignored.packages(env_package_name())
#> 
#> # Ensure renv/local directory exists and is clean -------------------------
#> 
#> renv_ensure_local_dir()
#> 
#> # Build -------------------------------------------------------------------
#> 
#> build_into_renv_local()
#> 
#> # Remove dev package ------------------------------------------------------
#> 
#> renv_remove_dev_package()
#> 
#> # Create snapshot ---------------------------------------------------------
#> 
#> renv_snapshot()
#> 
#> # Manage cached {renv} lockfile -------------------------------------------
#> 
#> renv_manage_cached_lockfile()
#> 
#> renv_add_lockfile_record()
#> 
#> # Preps for Docker --------------------------------------------------------
#> 
#> renv_ensure_cache_docker_dir()
#> 
#> renv_copy_description()
```

1.  Generate `docker_build.sh` and `docker_run.sh`

``` r
build_build_sh <- use_template_docker_build(open = FALSE)
#> ✓ Adding '^/Users/jankothyson/Code2/R/Packages/renv2docker/docker_build\\.sh$' to '.Rbuildignore'
#> ℹ Created /Users/jankothyson/Code2/R/Packages/renv2docker/docker_build.sh

readLines(build_build_sh) %>% cat(sep = "\n")
#> # Environment variables ----------
#> source .env
#> 
#> echo "Package name:"        $PACKAGE_NAME
#> echo "Package version:"     $PACKAGE_VERSION
#> echo "Package maintainer:"  $PACKAGE_MAINTAINER
#> echo "DCM name:"            $DCM_NAME
#> echo "R version:"           $R_VERSION
#> echo "{renv} version:"      $RENV_VERSION
#> 
#> # Build R package ----------
#> Rscript -e 'source("renv/activate.R")' -e 'source("build.R")'
#> 
#> # Dependency cache manager: build image ----------
#> docker build -t $DCM_NAME --build-arg PACKAGE_NAME=$PACKAGE_NAME --build-arg PACKAGE_VERSION=$PACKAGE_VERSION --build-arg PACKAGE_MAINTAINER=$PACKAGE_MAINTAINER --build-arg R_VERSION=$R_VERSION --build-arg RENV_VERSION=$RENV_VERSION -f renv/Dockerfile renv
#> 
#> # Dependency cache manager: run container ----------
#> # Ensures that packages are installed/built via {renv} inside the container and persisted to the host directory
#> docker run --rm -v $(pwd)/renv/cache_docker:/root/.local/share/renv $DCM_NAME
#> 
#> # Build image ----------
#> docker build -t $PACKAGE_NAME --build-arg PACKAGE_NAME=$PACKAGE_NAME --build-arg PACKAGE_VERSION=$PACKAGE_VERSION --build-arg PACKAGE_MAINTAINER=$PACKAGE_MAINTAINER --build-arg R_VERSION=$R_VERSION .
```

``` r
docker_run_sh <- use_template_docker_run(open = FALSE)
#> ✓ Adding '^/Users/jankothyson/Code2/R/Packages/renv2docker/docker_run\\.sh$' to '.Rbuildignore'
#> ℹ Created /Users/jankothyson/Code2/R/Packages/renv2docker/docker_run.sh

readLines(docker_run_sh) %>% cat(sep = "\n")
#> # Environment variables ----------
#> PACKAGE_NAME=$(cat .docker_env_package_name)
#> PACKAGE_PORT=$(cat .docker_env_package_port)
#> 
#> docker run --rm -p 127.0.0.1:$PACKAGE_PORT:$PACKAGE_PORT $PACKAGE_NAME
#> # -v $(pwd)/logs:/service/logs
```

1.  Modify the desired R script to be run inside the Docker container

Find line

    COPY inst/main.R main.R

and line

    CMD Rscript 'main.R'

and adapt it to your setup.

The default setup

-   expects a file `main.R` within your `inst` directory
-   copies that into the Docker image as file `main.R`
-   Runs `main.R` via `Rscript`

1.  Build your Docker container

Open a terminal/shell within your package/project root directory and
type

    ./docker_build.sh

1.  Run your Docker container

<!-- -->

    ./docker_run.sh

## Shout outs

This package was inspired and influenced by

-   [Colin Fay: An Introduction to Docker for R
    Users](https://colinfay.me/docker-r-reproducibility/)
-   [ColinFay/dockerfiler](https://github.com/ColinFay/dockerfiler)
-   [ThinkR/devindocker](https://github.com/ThinkR-open/devindocker)
-   [Eric Nantz: R Dev
    Projects](https://github.com/rpodcast/r_dev_projects)

My goal is to align this package as much as I can with existing
workflows and best practices around R in combination with Docker.

## TODOs

-   Learn much more about Docker ;-)
-   Thoroughly investigate existing tooling around R and docker -
    especially the packages and workflows mentioned in the shout outs -
    to see where I can improve the package by better aligning it with
    best practices

## DISCLAIMER

This is another one of my “scratch your own itch” type of projects.

I use Linux ([Pop!\_OS](https://pop.system76.com/)) and hence aligned
`{renv}` and Docker workflows to that platform –&gt; not sure how much
of it is applicable for MacOS or Windows

Still hope it works for other developers out there as well :-)

## Code of Conduct

Please note that the renv2docker project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
