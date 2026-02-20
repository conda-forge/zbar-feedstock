#!/bin/bash
set -exo pipefail

# The release tarball already ships a working configure script.
# On Windows, autoreconf fails because autoconf cannot find its m4 data
# in the mixed MSYS2+conda environment. We skip it on Windows since the
# shipped configure is perfectly usable.
if [[ "${target_platform}" != win-* ]]; then
    autoreconf -vfi
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

# patch_libtool is provided by autotools_clang_conda on Windows; it must be
# called after configure to fix the generated libtool script for DLL creation.
if [[ "${target_platform}" == win-* ]]; then
    patch_libtool
fi

make
make install
