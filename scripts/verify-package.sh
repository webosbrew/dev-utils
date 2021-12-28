#!/bin/sh

PKG="$1"

if [ ! -f "${PKG}" ]; then
  echo "Usage: $0 package"
  exit 1
fi
verify_symbols_sh=$(dirname "$0")/verify-symbols.sh

verify_symbols() {
  ${verify_symbols_sh} $1
}

temp_dir="/tmp/.webos-pkg-verify-$(date +%s)"

mkdir -p "${temp_dir}" || exit 1

ar x "${PKG}" --output="${temp_dir}"

tar zx -f "${temp_dir}/data.tar.gz" -C "${temp_dir}"

for appinfo in $(find "${temp_dir}" -name 'appinfo.json'); do
  if [ $(jq -r '.type' "$appinfo") != 'native' ]; then
    echo "Skipping non-native app $(basename $(dirname $appinfo))"
    continue
  fi
  echo "Checking app $(basename $(dirname $appinfo))."
  echo "======"
  app_dir=$(dirname "$appinfo")
  main_exe=${app_dir}/$(jq -r '.main' "$appinfo")
  lib_dir=${app_dir}/lib
  echo "Result for $(basename $main_exe):"
  echo "------"
  WEBOS_LD_LIBRARY_PATH="${lib_dir}" verify_symbols "${main_exe}"
  echo
  echo
  for lib in $(find "${lib_dir}" -type f); do
    echo "Result for $(basename $lib):"
    echo "------"
    WEBOS_LD_LIBRARY_PATH="${lib_dir}" verify_symbols "${lib}"
    echo
    echo
  done
done

rm -rf "${temp_dir}"