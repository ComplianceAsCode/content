#!/bin/bash
PRODUCT=$1 # parameter passed from .devcontainer.json files
WORKSHOP=$2 # parameter passed from .devcontainer.json files
[ -z "$PRODUCT" ] && PRODUCT="fedora"
[ -z "$CONTAINER" ] && CONTAINER=$PRODUCT
[ -z "$CONTAINER_VERSION" ] && CONTAINER_VERSION="$CONTAINER"
mkdir -p .vscode && cp .gitpod.launch.json .vscode/launch.json
CONTAINER_NAME=${CONTAINER}_container
sed -i "s/&&CONTAINER_NAME&&/$CONTAINER_NAME/g" .vscode/launch.json
sed -i "s/&&DEFAULT_PRODUCT&&/$PRODUCT/g" .vscode/launch.json
PRIVATE_KEY_FOLDER=.ssh
PRIVATE_KEY_FILEPATH=$PRIVATE_KEY_FOLDER/id_rsa
sed -i "s,&&PRIVATE_KEY_FILEPATH&&,$PRIVATE_KEY_FILEPATH,g" .vscode/launch.json
mkdir -p $PRIVATE_KEY_FOLDER
ssh-keygen -N '' -f $PRIVATE_KEY_FILEPATH
# set correct SSH permissions
chmod 600 $PRIVATE_KEY_FILEPATH
docker build --build-arg "CLIENT_PUBLIC_KEY=$(cat $PRIVATE_KEY_FILEPATH.pub)" -t $CONTAINER_NAME --build-arg IMAGE=$CONTAINER_VERSION -f Dockerfiles/test_suite-$CONTAINER .
[ -n "$WORKSHOP" ] && ansible-playbook -i 127.0.0.1, docs/workshop/labs_setup.yml -e EXERCISE="$WORKSHOP" -e LAB_DIR="$(pwd)" --connection=local -u vscode --ssh-extra-args '-F docs/workshop/data/ssh_config'
[ -z "$WORKSHOP" ] && ./build_product $PRODUCT --datastream-only

exit 0
