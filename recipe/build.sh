#!/bin/bash
set -exo pipefail

# The release tarball already ships the gettext infrastructure files that
# autopoint would generate. autopoint fails on Windows because the gettext
# archive data is not available in the build environment, so stub it out.
if [[ "${target_platform}" == win-* ]]; then
    export AUTOPOINT=true
    # Force autoreconf to use the conda-installed autotools, not the MSYS2 system ones.
    # The MSYS2 /usr/bin/autoconf cannot find its own m4 data in this environment.
    # On Windows, conda-forge autotools install to Library/usr/bin/, not Library/bin/.
    export AUTOCONF="${BUILD_PREFIX}/Library/usr/bin/autoconf"
    export AUTOHEADER="${BUILD_PREFIX}/Library/usr/bin/autoheader"
    export AUTOMAKE="${BUILD_PREFIX}/Library/usr/bin/automake"
    export ACLOCAL="${BUILD_PREFIX}/Library/usr/bin/aclocal"
    export ACLOCAL_PATH="${BUILD_PREFIX}/Library/usr/share/aclocal:${ACLOCAL_PATH:-}"
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
