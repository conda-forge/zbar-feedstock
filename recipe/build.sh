#!/bin/bash
set -exo pipefail

if [[ "${target_platform}" == win-* ]]; then
    export AUTOPOINT=true
    # aclocal is an MSYS2 tool and needs MSYS2-style paths.
    # The conda build prefix on Windows is e.g. D:/bld/.../build_env/Library,
    # which in MSYS2 bash appears as /d/bld/.../build_env/Library.
    # Convert BUILD_PREFIX to an MSYS2 path and point aclocal to the m4 files
    # installed there by conda packages (gettext, libiconv).
    _build_prefix_msys=$(cygpath -u "${BUILD_PREFIX}")
    export ACLOCAL_PATH="${_build_prefix_msys}/Library/usr/share/aclocal:${_build_prefix_msys}/Library/share/aclocal:${ACLOCAL_PATH:-}"
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
