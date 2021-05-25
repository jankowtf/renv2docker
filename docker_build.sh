# Environment variables ----------
source .env

echo "Package name:"        $PACKAGE_NAME
echo "Package version:"     $PACKAGE_VERSION
echo "Package maintainer:"  $PACKAGE_MAINTAINER
echo "DCM name:"            $DCM_NAME
echo "R version:"           $R_VERSION
echo "{renv} version:"      $RENV_VERSION

# Build R package ----------
Rscript -e 'source("renv/activate.R")' -e 'source("build.R")'

# Dependency cache manager: build image ----------
docker build -t $DCM_NAME \
--build-arg PACKAGE_NAME=$PACKAGE_NAME \
--build-arg PACKAGE_VERSION=$PACKAGE_VERSION \
--build-arg PACKAGE_MAINTAINER=$PACKAGE_MAINTAINER \
--build-arg R_VERSION=$R_VERSION \
--build-arg RENV_VERSION=$RENV_VERSION \
-f renv/Dockerfile renv

# Dependency cache manager: run container ----------
# Ensures that packages are installed/built via {renv} inside the container and persisted to the host directory
docker run --rm -v $(pwd)/renv/cache_docker:/root/.local/share/renv $DCM_NAME

# Build image ----------
docker build -t $PACKAGE_NAME \
--build-arg PACKAGE_NAME=$PACKAGE_NAME \
--build-arg PACKAGE_VERSION=$PACKAGE_VERSION \
--build-arg PACKAGE_MAINTAINER=$PACKAGE_MAINTAINER \
--build-arg R_VERSION=$R_VERSION .
