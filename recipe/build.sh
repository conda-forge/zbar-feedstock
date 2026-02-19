#!/bin/bash

set -exo pipefail

autoreconf -vfi
./configure --prefix=$PREFIX \
            --disable-video \
            --without-gtk \
            --without-python \
            --without-qt \
            --without-imagemagick \
            --without-xv \
            --without-x \
            --without-xshm
make
make install
