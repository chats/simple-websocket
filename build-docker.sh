#!/bin/bash

PLATFORM=linux/amd64,linux/arm64
TAG=chats/simple-websocket

docker buildx build --platform=$PLATFORM -t $TAG --attest type=provenance --attest type=sbom .