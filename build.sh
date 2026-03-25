#!/bin/bash

HERE=$(dirname $0)

REPO=wearejh/ci-build-env
IMAGE_URI=${REPO}:8.5-comp2

# Pull current build for comparison before publish
docker pull ${IMAGE_URI}
docker tag ${IMAGE_URI} ${IMAGE_URI}-current

# Set the required version in the Dockerfile
sed -i -e "s/{{PHP_VERSION}}/8.5/g" Dockerfile
sed -i -e "s/{{COMPOSER_VERSION}}/2/g" Dockerfile
sed -i -e "s/{{GITHUB_TOKEN}}/${GITHUB_TOKEN}/g" Dockerfile

if [ "$1" = "--debug" ]; then
    docker build --no-cache -f Dockerfile -t ${IMAGE_URI} ${HERE} --progress=plain &> build.log
    echo "Build output written to build.log"
else
    docker build --no-cache -f Dockerfile -t ${IMAGE_URI} ${HERE}
fi