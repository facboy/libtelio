#!/bin/bash

export ARCH="aarch64"
export OPENWRT_TARGET="rockchip-armv8"
export OPENWRT_RELEASE="25.12.6"

git submodule update --init 3rd-party/rust_build_utils

docker build \
  --pull \
  -f 3rd-party/rust_build_utils/builders/build-openwrt-rust/Dockerfile \
  -t build-openwrt-rust \
  3rd-party/rust_build_utils

docker run \
  --rm \
  -v "$(pwd)":/src \
  -w /src \
  build-openwrt-rust \
  python3 ci/build_libtelio.py build openwrt "$ARCH"

mkdir -p "dist/openwrt/release/${OPENWRT_TARGET}/${OPENWRT_RELEASE}"
chmod -R 0777 "dist/openwrt/release/${OPENWRT_TARGET}"

docker run \
  --rm \
  --pull always \
  -v "$(pwd)":/src \
  "openwrt/sdk:${OPENWRT_TARGET}-${OPENWRT_RELEASE}" \
  bash /src/3rd-party/rust_build_utils/builders/package-openwrt/package.sh \
    /src/clis/nordvpnlite/openwrt/feed \
    src-link \
    "/src/dist/openwrt/release/${ARCH}/nordvpnlite" \
    nordvpnlite \
    "/src/dist/openwrt/release/${OPENWRT_TARGET}/${OPENWRT_RELEASE}"
