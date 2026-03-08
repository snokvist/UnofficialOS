# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present UnofficialOS

PKG_NAME="gstreamer-rockchip"
PKG_VERSION="99c594d3090ee1b4721ef0a9c1e4a99ea3de52e9"
PKG_SHA256="d0a0d2dc134026400fc9321d05a67355e13da597032042c943f01e6e2bdc47dd"
PKG_ARCH="arm aarch64"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://github.com/Meonardo/gst-rockchip"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gstreamer gst-plugins-base rkmpp librga"
PKG_LONGDESC="GStreamer plugins for Rockchip MPP hardware video encode/decode"
PKG_TOOLCHAIN="meson"

pre_configure_target() {
  # librga headers are in /usr/include/rga/ but code expects #include <rga.h>
  export CFLAGS="${CFLAGS} -I${SYSROOT_PREFIX}/usr/include/rga"
  PKG_MESON_OPTS_TARGET="-Dkmssrc=disabled \
                         -Drkximage=disabled \
                         -Dvpxalphadec=disabled \
                         -Drga=enabled \
                         -Drockchipmpp=enabled"
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/share
}
