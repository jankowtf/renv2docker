# Rscript -e 'source("renv/activate.R")' -e 'source("build.R")'
# R_PACKAGE_NAME="horst"

echo "R_PACKAGE_NAME"
R_PACKAGE_NAME=$(cat .docker_env_package_name);
echo ${R_PACKAGE_NAME}
