# References
# Overall: https://cran.r-project.org/web/packages/renv/vignettes/docker.html
# Handling local sources: https://rstudio.github.io/renv/articles/local-sources.html
# Ignoring dev dependencies: https://rstudio.github.io/renv/articles/faq.html
# ARG for FROM: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

ARG  R_VERSION
FROM rocker/r-ver:$R_VERSION

ARG PACKAGE_NAME
ARG PACKAGE_VERSION
ARG PACKAGE_MAINTAINER

LABEL version=$PACKAGE_VERSION
LABEL maintainer=$PACKAGE_MAINTAINER

# Install Linux libs ----------
RUN apt-get update && \
  apt-get autoremove && \
  apt-get autoclean && \
  apt-get install \
  -y \
  --force-yes \
  -f \
  libsasl2-dev \
  libssl-dev \
  libcurl4 \
  libcurl4-openssl-dev \
  libxml2-dev \
  libsodium-dev \
  libz-dev \
  zlib1g-dev

# Copy dependency cache ----------
#RUN echo $(ls -a -1)
RUN mkdir -p /root/.local/share/renv
COPY renv/cache_docker/ /root/.local/share/renv
RUN echo $(ls -a -1 /root/.local/share/renv)

# Copy service components ----------
WORKDIR /service
RUN mkdir -p /service/logs
COPY renv.lock renv.lock
COPY renv/local renv/local
COPY renv/activate.R  renv/activate.R

COPY DESCRIPTION_OUTER DESCRIPTION
COPY inst/main.R main.R
# COPY .Rprofile .Rprofile

# Restore dependencies from cache ----------
RUN R \
  -e 'options("repos" = "https://packagemana¸ger.rstudio.com/all/__linux__/focal/latest")' \
  -e 'source("renv/activate.R")' \
  -e 'Sys.setenv(RENV_PATHS_LOCAL="renv/local")' \
  -e 'renv::restore()'

# Serve microservice via API ----------
CMD Rscript 'main.R'
