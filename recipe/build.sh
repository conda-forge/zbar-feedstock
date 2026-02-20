#!/bin/bash
set -exo pipefail

if [[ "${target_platform}" == win-* ]]; then
    export AUTOPOINT=true
    _build_prefix_msys=$(cygpath -u "${BUILD_PREFIX}")
    export ACLOCAL_PATH="${_build_prefix_msys}/Library/usr/share/aclocal:${_build_prefix_msys}/Library/share/aclocal:${ACLOCAL_PATH:-}"

    # Debug: find where autoconf's m4 data actually is
    find "${_build_prefix_msys}/Library" -name "m4sugar.m4" 2>/dev/null || echo "m4sugar.m4 not found under Library"
    find /usr -name "m4sugar.m4" 2>/dev/null || echo "m4sugar.m4 not found under /usr"
    head -5 "${_build_prefix_msys}/Library/usr/bin/autoconf" || true
fi

autoreconf -vfi

CONFIGURE_ARGS=(
    --prefix=$PREFIX
    --disable-video
    --without-gtk
    --without-python
    --without-qt
    --without-imagemagick
    --without-xv
    --without-x
    --without-xshm
)

if [[ "${target_platform}" == win-* ]]; then
    CONFIGURE_ARGS+=(--with-directshow)
else
    CONFIGURE_ARGS+=(--without-directshow)
fi

./configure "${CONFIGURE_ARGS[@]}"

if [[ "${target_platform}" == win-* ]]; then
    patch_libtool
fi

make
make install
