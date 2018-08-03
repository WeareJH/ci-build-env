#!/bin/sh

HERE=$(dirname $0)

PHPVER=${1}
REPO=wearejh/ci-build-env
SUPPORTED=(5.6 7.0 7.1)

if [ ${#PHPVER} -lt 1 ]; then
    echo "build.sh php-version"
    exit
fi

if [[ ! " ${SUPPORTED[@]} " =~ " ${PHPVER} " ]]; then
    echo "PHP version ${PHPVER} not supported"
    exit
fi

# Pull current build for comparison before punblish
docker pull ${REPO}:${PHPVER}
docker tag ${REPO}:${PHPVER} ${REPO}:${PHPVER}-current

# 5.6 is Legacy so is handles separately
if [ ${PHPVER} == 5.6 ]; then
    docker build --no-cache -f 5.6/Dockerfile -t ${REPO}:${PHPVER} ${HERE}
    exit
fi

# PHP 7.x share a common Dockerfile
# Set the required version in the Dockerfile
sed -i -e "s/{{VERSION}}/${PHPVER}/g" Dockerfile
docker build --no-cache -f Dockerfile -t ${REPO}:${PHPVER} ${HERE}