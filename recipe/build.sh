#! /bin/bash

set -exo pipefail
# Get an updated config.sub and config.guess
# cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

autoreconf -vfi

./configure --prefix=$PREFIX  --disable-video --without-gtk --without-python --without-qt --without-imagemagick --without-xv --without-x --without-xshm
make
# if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
# make check
# fi
make install
