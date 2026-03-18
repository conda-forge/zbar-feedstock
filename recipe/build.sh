#!/bin/bash
set -exo pipefail

if [[ "${target_platform}" == win-* ]]; then
    export AUTOPOINT=true
    _build_prefix_msys=$(cygpath -u "${BUILD_PREFIX}")
    export ACLOCAL_PATH="${_build_prefix_msys}/Library/usr/share/aclocal:${_build_prefix_msys}/Library/share/aclocal:${ACLOCAL_PATH:-}"

    # autoreconf ignores $AUTOCONF and calls /usr/bin/autoconf directly.
    # The MSYS2 /usr/bin/autoconf looks for its m4 data in /usr/share/autoconf/,
    # but that install is broken in this environment. Point it to the conda one.
    export AC_MACRODIR="${_build_prefix_msys}/Library/usr/share/autoconf"
    # autom4te (called by autoconf) uses this to find its Perl library and m4 data
    export autom4te_perllibdir="${_build_prefix_msys}/Library/usr/share/autoconf"
    export AUTOM4TE_CFG="${_build_prefix_msys}/Library/usr/share/autoconf/autom4te.cfg"
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
