#!/usr/bin/env bash
# ============================================================
#  Build Bernese Docker Image
# ============================================================

set -e

IMAGE_NAME="bernese54-runtime"

docker build \
    --build-arg HTTP_PROXY="${HTTP_PROXY:-}" \
    --build-arg HTTPS_PROXY="${HTTPS_PROXY:-}" \
    --build-arg NO_PROXY="${NO_PROXY:-}" \
    -t "${IMAGE_NAME}" \
    .