#!/bin/sh

. /opt/webos-sdk-x86_64/1.0.g/environment-setup-armv7a-neon-webos-linux-gnueabi

CMAKE_BIN=$(which cmake)

IS_CONFIGURE=1
while getopts ":t:-:" arg; do
  case $arg in
  t) IS_CONFIGURE=0 ;;
  -)
    case $OPTARG in
    build) IS_CONFIGURE=0 ;;
    install) IS_CONFIGURE=0 ;;
    target) IS_CONFIGURE=0 ;;
    *) ;;
    esac
    ;;
  *) ;;
  esac
done

if [ ${IS_CONFIGURE} = 1 ]; then
  toolchain_opt="-DCMAKE_TOOLCHAIN_FILE=$OECORE_NATIVE_SYSROOT/usr/share/cmake/OEToolchainConfig.cmake"
  exec "$CMAKE_BIN" "${toolchain_opt}" "$@"
else
  exec "$CMAKE_BIN" "$@"
fi
