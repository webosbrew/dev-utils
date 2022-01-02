#!/bin/sh

. /opt/webos-sdk-x86_64/1.0.g/environment-setup-armv7a-neon-webos-linux-gnueabi

CMAKE_TOOLCHAIN_OPT="-DCMAKE_TOOLCHAIN_FILE=$OECORE_NATIVE_SYSROOT/usr/share/cmake/OEToolchainConfig.cmake"
CMAKE_COMMAND=$(which cmake)

if [ '--build' = "$1" ]; then
  CMAKE_TOOLCHAIN_OPT=""
fi

$CMAKE_COMMAND "$CMAKE_TOOLCHAIN_OPT" "$@"
