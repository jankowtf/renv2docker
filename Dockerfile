# References
# Overall: https://cran.r-project.org/web/packages/renv/vignettes/docker.html
# Handling local sources: https://rstudio.github.io/renv/articles/local-sources.html
# Ignoring dev dependencies: https://rstudio.github.io/renv/articles/faq.html

#FROM r-base
FROM rocker/r-ver:4.0.3

LABEL version="0.0.0.9000"
LABEL maintainer="janko.thyson@rappster.io"

# Install Linux libs ----------
#RUN apt-get update && apt-get install -y libsasl2-dev libssl-dev libcurl4 libcurl4-openssl-dev libxml2-dev libsodium-dev
#RUN apt-get update && apt-get dist-upgrade -y --force-yes && apt-get autoremove && apt-get autoclean && apt-get install -y --force-yes -f libsasl2-dev libssl-dev libcurl4 libcurl4-openssl-dev libxml2-dev libsodium-dev
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
#COPY config.yml config.yml
COPY start.R  start.R

# Restore dependencies from cache ----------
RUN echo "Package repository"
RUN R -e 'getOption("repos")'
RUN R -e 'options("repos" = "https://packagemanager.rstudio.com/all/__linux__/focal/latest")'
RUN R -e 'getOption("repos")'
#RUN R -e 'source("renv/activate.R")' -e 'renv::restore()' -e 'renv::snapshot()'
RUN R -e 'source("renv/activate.R")' -e 'renv::restore()'

# Serve microservice via API ----------
CMD Rscript 'start.R'
