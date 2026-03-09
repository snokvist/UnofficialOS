# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present snokvist (joakim.snokvist@gmail.com)

PKG_NAME="waybeam-hub"
PKG_VERSION="14a556363489745ed932ae6af161540f78a087bb"
PKG_LICENSE="Autod Personal Use"
PKG_SITE="https://github.com/snokvist/waybeam-hub"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="main"
PKG_DEPENDS_TARGET="toolchain gstreamer gst-plugins-base libdrm systemd libpng rkmpp"
PKG_TOOLCHAIN="manual"

make_target() {
  # Let the Makefile keep its own CFLAGS/LDFLAGS (-Isrc -Ivendor/cjson etc.)
  # Only override CC and PKG_CONFIG for cross-compilation
  make CC="${CC}" \
       PKG_CONFIG="${PKG_CONFIG}" \
       ground-full
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp build/ground-full/waybeam_hub ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr/config/waybeam-hub
  cp ${PKG_BUILD}/configs/waybeam_ground.conf ${INSTALL}/usr/config/waybeam-hub/
  cp ${PKG_BUILD}/configs/waybeam_osd.json ${INSTALL}/usr/config/waybeam-hub/

  # Systemd service
  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cat > ${INSTALL}/usr/lib/systemd/system/waybeam-hub.service <<'UNIT'
[Unit]
Description=Waybeam Hub ground station
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/waybeam_hub -c /storage/.config/waybeam-hub/waybeam_ground.conf
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
UNIT
}
