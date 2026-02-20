#!/bin/bash
set -exo pipefail

if [[ "${target_platform}" == win-* ]]; then
    export AUTOPOINT=true
    # On Windows, autoconf cannot find its own m4 data directory via the
    # conda-installed binary. Point it explicitly to the right location.
    export AUTOCONF="${BUILD_PREFIX}/Library/usr/bin/autoconf"
    export AUTOHEADER="${BUILD_PREFIX}/Library/usr/bin/autoheader"
    export AUTOMAKE="${BUILD_PREFIX}/Library/usr/bin/automake"
    export ACLOCAL="${BUILD_PREFIX}/Library/usr/bin/aclocal"
    export ACLOCAL_PATH="${BUILD_PREFIX}/Library/usr/share/aclocal:${ACLOCAL_PATH:-}"
    export M4PATH="${BUILD_PREFIX}/Library/usr/share/autoconf:${BUILD_PREFIX}/Library/usr/share/aclocal:${M4PATH:-}"
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
