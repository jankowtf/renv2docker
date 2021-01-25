# Environment variables ----------
R_PACKAGE_NAME=$(cat .docker_env_package_name);
R_PACKAGE_VERSION=$(cat .docker_env_package_version)
R_PACKAGE_MAINTAINER=$(cat .docker_env_package_maintainer)

R_VERSION=$(cat .docker_env_r_version)
RENV_VERSION=$(cat .docker_env_renv_version)

R_PACKAGE_NAME_DEPS=$(cat .docker_env_dependency_manager_name);

# Build R package ----------
Rscript -e 'source("renv/activate.R")' -e 'source("build.R")'

# Dependency cache manager: build image ----------
docker build -t $R_PACKAGE_NAME_DEPS --build-arg R_PACKAGE_NAME=$R_PACKAGE_NAME --build-arg R_PACKAGE_VERSION=$R_PACKAGE_VERSION --build-arg R_PACKAGE_MAINTAINER=$R_PACKAGE_MAINTAINER --build-arg R_VERSION=$R_VERSION --build-arg RENV_VERSION=$RENV_VERSION -f renv/Dockerfile renv

# Dependency cache manager: run container ----------
# Ensures that packages are installed/built via {renv} inside the container and persisted to the host directory
docker run --rm -v $(pwd)/renv/cache_docker:/root/.local/share/renv $R_PACKAGE_NAME_DEPS

# Build image ----------
docker build -t $R_PACKAGE_NAME --build-arg R_PACKAGE_NAME=$R_PACKAGE_NAME --build-arg R_PACKAGE_VERSION=$R_PACKAGE_VERSION --build-arg R_PACKAGE_MAINTAINER=$R_PACKAGE_MAINTAINER --build-arg R_VERSION=$R_VERSION .
