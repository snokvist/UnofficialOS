# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="librga"
PKG_VERSION="2cffdf6f332c3ddb93eb087841d78e8b487db2a3"
PKG_SHA256="cf025013917c1f96c177d025e63b7a5258a132e24c666b1c599155a94dcee6b3"
PKG_ARCH="arm aarch64"
PKG_LICENSE="Apache-2.0"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_SITE="https://github.com/tsukumijima/librga-rockchip"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Rockchip RGA userspace library"
PKG_TOOLCHAIN="meson"

post_makeinstall_target() {
  # rga headers install to /usr/include/rga/ — fix pkgconfig so #include <rga.h> works
  sed -i 's|Cflags: -I${includedir}$|Cflags: -I${includedir} -I${includedir}/rga|' \
    ${INSTALL}/usr/lib/pkgconfig/librga.pc
  # Stub RockchipRgaMacro.h for backwards compat with older consumers (e.g. RetroArch OGA driver)
  echo -e "#ifndef _ROCKCHIP_RGA_MACRO_H_\n#define _ROCKCHIP_RGA_MACRO_H_\n#endif" \
    > ${INSTALL}/usr/include/rga/RockchipRgaMacro.h
}
