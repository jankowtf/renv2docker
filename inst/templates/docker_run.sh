# Environment variables ----------
PACKAGE_NAME=$(cat .docker_env_package_name)
PACKAGE_PORT=$(cat .docker_env_package_port)

docker run --rm -p 127.0.0.1:$PACKAGE_PORT:$PACKAGE_PORT $PACKAGE_NAME
# -v $(pwd)/logs:/service/logs
