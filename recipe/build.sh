#!/bin/bash

set -exo pipefail

# Upstream dropped autotools in 0.23.95 in favor of meson
meson setup build \
    ${MESON_ARGS} \
    -Dlibrary_type=both \
    -Dvideo=false \
    -Dgtk=no \
    -Dgir=false \
    -Dpython=no \
    -Dqt=false \
    -Djava=disabled \
    -Dimagemagick=disabled \
    -Dxv=disabled \
    -Dxshm=disabled \
    -Dx11=disabled \
    -Ddbus=disabled \
    -Ddoc=false \
    -Dbuild_tests=false
meson compile -C build
meson install -C build
