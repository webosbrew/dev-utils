#!/bin/sh
# Put in /opt/webos-sdk-x86_64/1.0.g/sysroots/x86_64-webossdk-linux/environment-setup.d
# and it will use system version of tools like CMake.

path_first=""
path_last=""

OLDIFS="$IFS"
IFS=:
for p in ${PATH}; do
  case "$p" in
  "${OECORE_NATIVE_SYSROOT}"*) path_last="${path_last}${p}:" ;;
  *) path_first="${path_first}${p}:" ;;
  esac
done
IFS="$OLDIFS"

NEWPATH="${path_first}${path_last}"
NEWPATH=$(printf %s "$NEWPATH" | awk -vRS=: '!a[$0]++' | paste -s -d:)

export PATH=${NEWPATH}