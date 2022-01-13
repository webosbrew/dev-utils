#!/bin/sh
# Buildroot Toolchain based cmake wrapper

FILEPATH="$(readlink -f "$0")"
SDKPATH="$(dirname "${FILEPATH}")"

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
  toolchain_opt="-DCMAKE_TOOLCHAIN_FILE=${SDKPATH}/share/buildroot/toolchainfile.cmake"
  exec "$CMAKE_BIN" "${toolchain_opt}" "$@"
else
  exec "$CMAKE_BIN" "$@"
fi