#!/bin/bash

HERE=$(dirname $0)

PHPVER=${1}
REPO=wearejh/ci-build-env
SUPPORTED=(7.1 7.2 7.3 7.4)
IMAGEVER=$(date '+%Y%m%d%H%M')

if [ ${#PHPVER} -lt 1 ]; then
    echo "build.sh php-version"
    exit
fi

if [[ ! " ${SUPPORTED[@]} " =~ " ${PHPVER} " ]]; then
    echo "PHP version ${PHPVER} not supported"
    exit
fi

docker tag $REPO:$PHPVER $REPO:$PHPVER-$IMAGEVER

# Compare image to current before push
LAYER_DIFF=$(diff <(docker inspect $REPO:$PHPVER | jq '.[0].RootFS.Layers') <(docker inspect $REPO:$PHPVER-current | jq '.[0].RootFS.Layers'))

if [ -z "${LAYER_DIFF}" ]; then
    echo "Looks like this is exactly the same as the current build... skipping publish"
    exit
fi

docker login -u $DOCKER_USER -p $DOCKER_PASS
docker push $REPO:$PHPVER
docker push $REPO:$PHPVER-$IMAGEVER
