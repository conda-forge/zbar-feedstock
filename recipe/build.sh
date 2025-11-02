#! /bin/bash

set -exo pipefail
# Get an updated config.sub and config.guess
# cp $BUILD_PREFIX/share/gnuconfig/config.* ./config
export PYTHON=$PREFIX/bin/python

autoreconf -vfi

./configure --prefix=$PREFIX  --disable-video --without-gtk --without-python --without-qt --without-imagemagick --without-xv --without-x --without-xshm

make

make install
