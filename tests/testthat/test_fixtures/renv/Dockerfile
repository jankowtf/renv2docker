# References
# Overall: https://cran.r-project.org/web/packages/renv/vignettes/docker.html
# Handling local sources: https://rstudio.github.io/renv/articles/local-sources.html
# Ignoring dev dependencies: https://rstudio.github.io/renv/articles/faq.html

ARG  R_VERSION=4.0.3

FROM rocker/r-ver:${R_VERSION}

ARG PACKAGE_MAINTAINER="janko.thyson@rappster.io"
ARG R_PACKAGE_NAME
ARG R_PACKAGE_VERSION
ARG RENV_VERSION

RUN echo "PACKAGE_MAINTAINER: $PACKAGE_MAINTAINER"
RUN echo "R_PACKAGE_NAME: $R_PACKAGE_NAME"
RUN echo "R_PACKAGE_VERSION: $R_PACKAGE_VERSION"
RUN echo "R_VERSION: $R_VERSION"
RUN echo "RENV_VERSION: $RENV_VERSION"

LABEL version=$R_PACKAGE_VERSION
LABEL maintainer='Janko Thyson (janko.thyson@rappster.io) [aut, cre]'

RUN R \
    -e 'options("repos" = "https://packagemanager.rstudio.com/all/__linux__/focal/latest")' \
    -e 'install.packages("remotes")' \
    -e 'renv_package <- paste0("rstudio/renv@", Sys.getenv("RENV_VERSION"))' \
    -e 'remotes::install_github(renv_package)'

# Copy required components for cache management ----------
WORKDIR /dcm
COPY renv.lock renv.lock

# Install Linux libs ----------
RUN apt-get update && \
  apt-get autoremove && \
  apt-get autoclean && \
  apt-get install \
  -y \
  --force-yes \
  -f libsasl2-dev \
  libssl-dev \
  libcurl4 \
  libcurl4-openssl-dev \
  libxml2-dev \
  libsodium-dev \
  libgit2-dev \
  zlib1g-dev \
  libz-dev

# Restore dependencies ----------
#RUN R -e 'renv::consent(provided = TRUE)'

# Build actual cache files ----------
CMD R --no-save \
    -e 'renv::consent(provided = TRUE)' \
    -e 'renv::activate()' \
    -e 'renv::restore()'
