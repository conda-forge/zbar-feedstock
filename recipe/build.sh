#!/bin/bash
set -exo pipefail

if [[ "${target_platform}" == win-* ]]; then
    export AUTOPOINT=true
    # Use the conda-installed autotools (Library/usr/bin/), not the MSYS2
    # system ones (/usr/bin/). The MSYS2 autoconf cannot find its m4 data
    # in this environment.
    # Tell autom4te (invoked by autoconf) where autoconf's own m4 library is.
    export AUTOM4TE="${BUILD_PREFIX}/Library/usr/bin/autom4te"
    export AUTOCONF="${BUILD_PREFIX}/Library/usr/bin/autoconf"
    export AUTOHEADER="${BUILD_PREFIX}/Library/usr/bin/autoheader"
    export AUTOMAKE="${BUILD_PREFIX}/Library/usr/bin/automake"
    export ACLOCAL="${BUILD_PREFIX}/Library/usr/bin/aclocal"
    _build_prefix_msys=$(cygpath -u "${BUILD_PREFIX}")
    export ACLOCAL_PATH="${_build_prefix_msys}/Library/usr/share/aclocal:${_build_prefix_msys}/Library/share/aclocal:${ACLOCAL_PATH:-}"
    # autom4te looks for its data files relative to the autoconf datadir;
    # set AC_MACRODIR so it finds m4sugar.m4, m4sh.m4 etc.
    export AC_MACRODIR="${_build_prefix_msys}/Library/usr/share/autoconf"
    export autom4te_perllibdir="${_build_prefix_msys}/Library/usr/share/autoconf"
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

# patch_libtool must be called after configure to fix the generated libtool
# script for DLL creation on Windows.
if [[ "${target_platform}" == win-* ]]; then
    patch_libtool
fi

make
make install
