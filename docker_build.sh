# Environment variables ----------
R_PACKAGE_NAME=$(cat .docker_env_package_name)
R_PACKAGE_NAME_DEPS=$(cat .docker_env_dependency_manager_name)

# Microservice: build R package ----------
# Rscript -e 'setwd("./service")' -e 'source("renv/activate.R")' -e 'source("build.R")'
Rscript -e 'source("renv/activate.R")' -e 'source("build.R")'

# Dependency cache manager: build image ----------
docker build -t $R_PACKAGE_NAME_DEPS -f renv/Dockerfile renv

# Dependency cache manager: run container ----------
# Ensures that packages are installed/built via {renv} inside the container and persisted to the host directory
docker run --rm -v $(pwd)/renv/cache_docker:/root/.local/share/renv $R_PACKAGE_NAME_DEPS

# Microservice: build image ----------
docker build -t $R_PACKAGE_NAME .


