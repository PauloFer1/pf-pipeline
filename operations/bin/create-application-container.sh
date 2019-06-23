#!/usr/bin/env bash
set -xe

while getopts ":du:v:" opt; do
  case $opt in
    d) CONTAINER_DEPLOY="1"
    ;;
    u) UPDATE_STREAM="$OPTARG"
    ;;
    v) VERSION="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

. tools/common/common.config

docker build -t $DOCKER_REGISTRY/$COMPONENT_CONTAINER_NAME:$VERSION -f tools/docker/Dockerfile.application .
docker build -t $DOCKER_REGISTRY/$DB_CONTAINER_NAME:$VERSION -f tools/docker/Dockerfile.db .

if [[ -n "$UPDATE_LATEST" ]]
then
    docker tag $DOCKER_REGISTRY/$COMPONENT_CONTAINER_NAME:$VERSION $DOCKER_REGISTRY/$COMPONENT_CONTAINER_NAME:$UPDATE_STREAM
    docker tag $DOCKER_REGISTRY/$DB_CONTAINER_NAME:$VERSION $DOCKER_REGISTRY/$DB_CONTAINER_NAME:$UPDATE_STREAM
fi

if [[ -n "$CONTAINER_DEPLOY" ]]
then
    docker push $DOCKER_REGISTRY/$COMPONENT_CONTAINER_NAME:$VERSION
    docker push $DOCKER_REGISTRY/$DB_CONTAINER_NAME:$VERSION

    if [[ -n "$UPDATE_LATEST" ]]
    then
        docker push $DOCKER_REGISTRY/$COMPONENT_CONTAINER_NAME:$UPDATE_STREAM
        docker push $DOCKER_REGISTRY/$DB_CONTAINER_NAME:$UPDATE_STREAM
    fi
fi
