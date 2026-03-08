# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present UnofficialOS

PKG_NAME="gst-plugins-ugly"
PKG_VERSION="$(get_pkg_version gstreamer)"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://gstreamer.freedesktop.org/modules/gst-plugins-ugly.html"
PKG_URL="https://gstreamer.freedesktop.org/src/gst-plugins-ugly/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain gstreamer gst-plugins-base"
PKG_LONGDESC="GStreamer Ugly Plug-ins"

PKG_MESON_OPTS_TARGET="-Dtests=disabled \
                       -Dnls=disabled \
                       -Da52dec=disabled \
                       -Dcdio=disabled \
                       -Ddvdread=disabled \
                       -Dmpeg2dec=disabled \
                       -Dsidplay=disabled \
                       -Dgobject-cast-checks=disabled \
                       -Dglib-asserts=disabled \
                       -Dglib-checks=disabled \
                       -Dpackage-name=gst-plugins-ugly \
                       -Dpackage-origin=unofficialos.org \
                       -Ddoc=disabled"

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/share
}
