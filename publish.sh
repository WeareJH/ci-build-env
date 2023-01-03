#!/bin/bash

HERE=$(dirname $0)

PHPVER=${1}
#composer version default to 1
[[ ${#2} -lt 1 ]] && COMPOSERVER=1 || COMPOSERVER=${2}
REPO=wearejh/ci-build-env
SUPPORTED=(7.4 8.1)
COMPOSER_SUPPORTED=(1 2)
IMAGEVER=$(date '+%Y%m%d%H%M')

#Check all parameters are present
if [ ${#PHPVER} -lt 1 ] || [ ${#COMPOSERVER} -lt 1 ]; then
    echo "build.sh php-version composer-version"
    exit
fi
#Check PHP version supplied is supported
if [[ ! " ${SUPPORTED[@]} " =~ " ${PHPVER} " ]]; then
    echo "PHP version ${PHPVER} not supported"
    exit
fi
#Check Composer version supplied is supported
if [[ ! " ${COMPOSER_SUPPORTED[@]} " =~ " ${COMPOSERVER} " ]]; then
    echo "Composer version ${COMPOSERVER} not supported"
    exit
fi
#construct docker image URI
[[ $COMPOSERVER -ge 2 ]] && COMP_SUFFIX="-comp2" || COMP_SUFFIX=""
IMAGE_URI=${REPO}:${PHPVER}${COMP_SUFFIX}
#create a tag containing the current time suffix
#so that it is possible to target a specific build
docker tag $IMAGE_URI $IMAGE_URI-$IMAGEVER

# Compare image to current before push
LAYER_DIFF=$(diff <(docker inspect $IMAGE_URI | jq '.[0].RootFS.Layers') <(docker inspect $IMAGE_URI-current | jq '.[0].RootFS.Layers'))

if [ -z "${LAYER_DIFF}" ]; then
    echo "Looks like this is exactly the same as the current build... skipping publish"
    exit
fi

docker login -u $DOCKER_USER -p $DOCKER_PASS
#Push both tags for this image, one generic and one tied to this specific timestamp.
docker push $IMAGE_URI
docker push $IMAGE_URI-$IMAGEVER
