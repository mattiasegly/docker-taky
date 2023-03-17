#!/bin/bash

DOCKER_REPO=mattiasegly/taky
SOURCE_BRANCH=bookworm

#Remove old images
for ARCH in amd64 i386 arm32v6 arm32v7 arm64v8
do
docker image rm $DOCKER_REPO:$SOURCE_BRANCH-$ARCH
done

docker image prune -f

#Pull base images
for ARCH in amd64 i386 arm32v6 arm32v7 arm64v8
do
docker pull mattiasegly/base-image:$SOURCE_BRANCH-$ARCH
done

#Build and push images
for ARCH in amd64 i386 arm32v6 arm32v7 arm64v8
do
docker build --no-cache -f Dockerfile -t $DOCKER_REPO:$SOURCE_BRANCH-$ARCH --build-arg ARCH=$ARCH --build-arg SOURCE_BRANCH=$SOURCE_BRANCH .
docker push $DOCKER_REPO:$SOURCE_BRANCH-$ARCH
done

#Create branch tag
docker manifest create \
	$DOCKER_REPO:$SOURCE_BRANCH \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-amd64 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-i386 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v6 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v7 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm64v8

docker manifest push --purge \
	$DOCKER_REPO:$SOURCE_BRANCH

#Create "latest" tag
docker manifest create \
	$DOCKER_REPO:latest \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-amd64 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-i386 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v6 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v7 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm64v8

docker manifest push --purge \
	$DOCKER_REPO:latest

#Clean up
for ARCH in amd64 i386 arm32v6 arm32v7 arm64v8
do
docker image rm $DOCKER_REPO:$SOURCE_BRANCH-$ARCH
done

docker image prune -f
