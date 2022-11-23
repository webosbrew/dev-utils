#!/bin/sh

export PKG_CONFIG="${OECORE_NATIVE_SYSROOT}/usr/bin/pkg-config"
alias pkg-config="${PKG_CONFIG}"
