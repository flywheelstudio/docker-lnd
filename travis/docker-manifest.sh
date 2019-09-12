#!/bin/bash
set -e

# make sure Docker's config folder exists
mkdir -p ~/.docker

# Putting experimental:true to config enables manifest options
echo '{ "experimental": "enabled" }' > ~/.docker/config.json

# put above config into effect
sudo systemctl restart docker

echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

# print this to verify manifest options are now available
docker version

# Example: lncm/lnd:0.6.0
IMAGE_VERSIONED="${SLUG}:${TRAVIS_TAG}"
IMAGE_AMD64="${IMAGE_VERSIONED}-linux-amd64"
IMAGE_ARM6="${IMAGE_VERSIONED}-linux-armv6"
IMAGE_ARM7="${IMAGE_VERSIONED}-linux-armv7"
IMAGE_ARM64="${IMAGE_VERSIONED}-linux-armv8"

docker pull "${IMAGE_AMD64}"
docker pull "${IMAGE_ARM6}"
docker pull "${IMAGE_ARM7}"
docker pull "${IMAGE_ARM64}"

echo     "Pushing manifest ${IMAGE_VERSIONED}"
docker -D manifest create "${IMAGE_VERSIONED}"  "${IMAGE_AMD64}"  "${IMAGE_ARM6}"  "${IMAGE_ARM7}"
docker manifest annotate  "${IMAGE_VERSIONED}"  "${IMAGE_ARM6}"  --os linux  --arch arm  --variant v6
docker manifest annotate  "${IMAGE_VERSIONED}"  "${IMAGE_ARM7}"  --os linux  --arch arm  --variant v7
docker manifest annotate "${IMAGE_VERSIONED}" "${IMAGE_ARM64}" --os linux --arch arm64 --variant v8
docker manifest push      "${IMAGE_VERSIONED}"


# example: lncm/lnd:0.6
IMAGE_MINOR_VER="${SLUG}:${VER}"

echo     "Pushing manifest ${IMAGE_MINOR_VER}"
docker -D manifest create "${IMAGE_MINOR_VER}"  "${IMAGE_AMD64}"  "${IMAGE_ARM6}"  "${IMAGE_ARM7}"
docker manifest annotate  "${IMAGE_MINOR_VER}"  "${IMAGE_ARM6}"  --os linux  --arch arm  --variant v6
docker manifest annotate  "${IMAGE_MINOR_VER}"  "${IMAGE_ARM7}"  --os linux  --arch arm  --variant v7
docker manifest annotate "${IMAGE_MINOR_VER}" "${IMAGE_ARM64}" --os linux --arch arm64 --variant v8
docker manifest push      "${IMAGE_MINOR_VER}"


#example: lncm/lnd:latest
IMAGE_LATEST="${SLUG}:latest"

echo     "Pushing manifest ${IMAGE_LATEST}"
docker -D manifest create "${IMAGE_LATEST}"  "${IMAGE_AMD64}"  "${IMAGE_ARM6}"  "${IMAGE_ARM7}"
docker manifest annotate  "${IMAGE_LATEST}"  "${IMAGE_ARM6}"  --os linux  --arch arm  --variant v6
docker manifest annotate  "${IMAGE_LATEST}"  "${IMAGE_ARM7}"  --os linux  --arch arm  --variant v7
docker manifest annotate "${IMAGE_LATEST}" "${IMAGE_ARM64}" --os linux --arch arm64 --variant v8
docker manifest push      "${IMAGE_LATEST}"
