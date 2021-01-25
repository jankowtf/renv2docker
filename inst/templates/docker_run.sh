# Environment variables ----------
R_PACKAGE_NAME=$(cat .docker_env_package_name)
R_PACKAGE_PORT=$(cat .docker_env_package_port)

docker run --rm -p 127.0.0.1:$R_PACKAGE_PORT:$R_PACKAGE_PORT $R_PACKAGE_NAME
# -v $(pwd)/logs:/service/logs
