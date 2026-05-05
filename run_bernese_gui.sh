#!/usr/bin/env bash
# ============================================================
#  Run Bernese GNSS Software GUI Directly
# ============================================================

set -e

IMAGE_NAME="bernese54-runtime"
CONTAINER_NAME="bernese54-gui-app"
SHARED_DIR="${HOME}/bernese54-shared"

MOUNT_GPSDATA=0

for arg in "$@"; do
    case "$arg" in
        --gpsdata)
            MOUNT_GPSDATA=1
            ;;
        -h|--help)
            echo "Usage: $0 [--gpsdata]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--gpsdata]"
            exit 1
            ;;
    esac
done

mkdir -p "${SHARED_DIR}/GPSWORK"
mkdir -p "${SHARED_DIR}/EXPORT"

DOCKER_ARGS=(
    --rm -it
    --name "${CONTAINER_NAME}"
    --hostname bernese54
    -e DISPLAY="${DISPLAY}"
    -e WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}"
    -e XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}"
    -e QT_X11_NO_MITSHM=1
    -e BERNESE_DEBUG=0
    -v /tmp/.X11-unix:/tmp/.X11-unix
    -v /mnt/wslg:/mnt/wslg
    -v "${SHARED_DIR}/GPSWORK:/home/bernese/GPSWORK"
    -v "${SHARED_DIR}/EXPORT:/home/bernese/EXPORT"
)

if [ "${MOUNT_GPSDATA}" = "1" ]; then
    mkdir -p "${SHARED_DIR}/GPSDATA/CAMPAIGN54"
    mkdir -p "${SHARED_DIR}/GPSDATA/DATAPOOL"
    mkdir -p "${SHARED_DIR}/GPSDATA/SAVEDISK"

    DOCKER_ARGS+=(
        -v "${SHARED_DIR}/GPSDATA:/home/bernese/GPSDATA"
    )
fi

docker run "${DOCKER_ARGS[@]}" \
    "${IMAGE_NAME}" \
    bash -lc 'G'
