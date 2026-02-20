#!/bin/bash
set -exo pipefail

# The release tarball already ships the gettext infrastructure files that
# autopoint would generate. autopoint fails on Windows because the gettext
# archive data is not available in the build environment, so stub it out.
if [[ "${target_platform}" == win-* ]]; then
    export AUTOPOINT=true
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

# patch_libtool is provided by autotools_clang_conda on Windows; it must be
# called after configure to fix the generated libtool script for DLL creation.
if [[ "${target_platform}" == win-* ]]; then
    patch_libtool
fi

make
make install
