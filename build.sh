#!/bin/bash

HERE=$(dirname $0)

PHPVER=${1}
#composer version default to 1
[[ ${#2} -lt 1 ]] && COMPOSERVER=1 || COMPOSERVER=${2}
REPO=wearejh/ci-build-env
SUPPORTED=(7.4 8.1 8.2 8.3)
COMPOSER_SUPPORTED=(1 2 2.2)

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

# Pull current build for comparison before publish
COMP_SUFFIX="-comp2"
IMAGE_URI=${REPO}:${PHPVER}${COMP_SUFFIX}

docker pull ${IMAGE_URI}
docker tag ${IMAGE_URI} ${IMAGE_URI}-current

# PHP 7.x share a common Dockerfile
# Set the required version in the Dockerfile
sed -i -e "s/{{PHP_VERSION}}/${PHPVER}/g" Dockerfile
sed -i -e "s/{{COMPOSER_VERSION}}/${COMPOSERVER}/g" Dockerfile
sed -i -e "s/{{GITHUB_TOKEN}}/${GITHUB_TOKEN}/g" Dockerfile
docker build --no-cache -f Dockerfile -t ${IMAGE_URI} ${HERE}
