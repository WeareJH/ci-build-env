#!/bin/bash

REPO=wearejh/ci-build-env
IMAGE_URI=${REPO}:8.4-comp2
IMAGEVER=$(date '+%Y%m%d%H%M')

# Create a tag containing the current time suffix
# so that it is possible to target a specific build
docker tag $IMAGE_URI $IMAGE_URI-$IMAGEVER

# Compare image to current before push
LAYER_DIFF=$(diff <(docker inspect $IMAGE_URI | jq '.[0].RootFS.Layers') <(docker inspect $IMAGE_URI-current | jq '.[0].RootFS.Layers'))

if [ -z "${LAYER_DIFF}" ]; then
    echo "Looks like this is exactly the same as the current build... skipping publish"
    exit
fi

docker login -u $DOCKER_USER -p $DOCKER_PASS
# Push both tags for this image, one generic and one tied to this specific timestamp.
docker push $IMAGE_URI
docker push $IMAGE_URI-$IMAGEVER