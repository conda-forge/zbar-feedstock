#!/bin/bash
set -exo pipefail

autoreconf -vfi

# autotools_clang_conda provides this on Windows to fix libtool DLL generation;
# on Unix it is not present so we skip it safely.
if [[ "${target_platform}" == win-* ]]; then
    patch_libtool
fi

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

make
make install
