# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rkmpp"
PKG_VERSION="8d694c802dd7c071e2cb6de878f9b1ddb8dcd975"
PKG_SHA256="42c598e179f325717cd9b23adef1c4af07528fe80fe877a7b285f10d09657ff3"
PKG_ARCH="arm aarch64"
PKG_LICENSE="APL"
PKG_SITE="https://github.com/HermanChen/mpp"
PKG_URL="https://github.com/HermanChen/mpp/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_LONGDESC="rkmpp: Rockchip Media Process Platform (MPP) module"

case ${DEVICE} in
  RK3326*|RK3566*)
    PKG_ENABLE_VP9D="ON"
  ;;
esac

PKG_CMAKE_OPTS_TARGET="-DENABLE_VP9D=${PKG_ENABLE_VP9D} \
                       -DHAVE_DRM=ON"
