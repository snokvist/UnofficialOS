# RK3566-BSP-RGB20Pro — Build Notes

## Device
**Powkiddy RGB20 Pro** — Rockchip RK3566 SoC, Mali bifrost-g52 GPU, HDMI output.

Derived from `RK3566-BSP`. Primary goal: slim build with GStreamer + rkmpp hardware
video stack for use with `waybeam-hub` (H.265 RTP video receiver).

---

## New packages added

### `packages/multimedia/gstreamer/gst-plugins-ugly/`
Created from scratch. Uses `$(get_pkg_version gstreamer)` to track the base gstreamer
version (1.24.x). Removed `-Dexamples=disabled` which was dropped in 1.24.x.

### `packages/multimedia/gstreamer/gstreamer-rockchip/`
Rockchip hardware video encode/decode GStreamer plugins.
- Source: `https://github.com/Meonardo/gst-rockchip` @ `99c594d3`
  (original `rockchip-linux/gstreamer-rockchip` is inaccessible/404)
- Depends on `rkmpp` and `librga`
- `pre_configure_target` exports `-I${SYSROOT_PREFIX}/usr/include/rga` so `#include <rga.h>` resolves

---

## Package fixes

### `packages/devel/librga/`
Switched from `RetroGFX/linux-rga` to `https://github.com/tsukumijima/librga-rockchip`
@ `2cffdf6f`. The old fork was missing `RK_FORMAT_YCbCr_422_SP_10B` used by gstreamer-rockchip.

`post_makeinstall_target` does two things:
1. Patches `librga.pc` to add `-I${includedir}/rga` so pkg-config consumers get the right include path
2. Creates a stub `RockchipRgaMacro.h` for backwards compat (retroarch OGA driver includes it)

### `packages/graphics/libmali/`
Added `PKG_TOOLCHAIN="meson"`. Without it the build system fails to auto-detect the
toolchain when both `meson.build` and other build files are present.

### `packages/multimedia/gstreamer/gst-plugins-bad/`
- Fixed empty `PKG_VERSION` → `$(get_pkg_version gstreamer)`
- Removed `-Dkate=disabled` (option removed in gst-plugins-bad 1.24.x)

### `packages/multimedia/libmpeg2/`
Dead SourceForge URL. Switched to VLC contrib mirror:
`https://download.videolan.org/contrib/libmpeg2/`

### `packages/devel/libffi/`
Upgraded `3.4.4` → `3.4.6`. GCC 14 on the host produces an implicit-declaration
error building the older version.

### `packages/textproc/xmlstarlet/`
Dead `netcologne.dl.sourceforge.net` mirror. Switched to `downloads.sourceforge.net`.

### `packages/compress/cpio/`
Upgraded `2.14` → `2.15`, switched URL to `https://` (http redirect was broken).

### `packages/devel/gnulib/`
Dead `git.savannah.gnu.org/gitweb/?p=...;sf=tgz` URL. The semicolons in the URL
caused wget to report "Scheme missing". Switched to GitHub mirror:
`https://github.com/coreutils/gnulib/archive/${PKG_VERSION}.tar.gz`

### `packages/sysutils/keyutils/`
Dead `people.redhat.com/~dhowells/keyutils/` URL. Switched to:
`https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git/snapshot/`

### `packages/multimedia/rkmpp/`
Switched to `https://github.com/HermanChen/mpp` at a newer commit with SHA256.

---

## Kernel (`packages/kernel/linux/`)

Two changes:

**1. Add RGB20Pro to kernel case**
```
RK3566-BSP|RK3566-BSP-RGB20Pro)
```
Both devices share the same kernel tree (`RetroGFX/rk356x-kernel`).

**2. Fix `resource.img` for single-DTB devices**

Original code always ran `mkmultidtb.py` (which creates a multi-DTB `resource.img`
with `rk-kernel.dtb` as the default). We added a guard so `mkmultidtb.py` is only
called when `DEVICE_DTB` has more than one entry.

**Problem**: Rockchip BSP u-boot specifically looks for `rk-kernel.dtb` inside
`resource.img`. When `mkmultidtb.py` is skipped, `scripts/mkimg` creates a
`resource.img` with the DTB stored under its original filename
(`rk3566-rgb20pro-linux.dtb`), which u-boot cannot find → boots without DTB →
no display, no peripherals.

**Fix** — for single-DTB builds, manually replicate what `mkmultidtb.py` does:
```bash
cp arch/arm64/boot/dts/rockchip/${DEVICE_DTB[0]}.dtb rk-kernel.dtb
scripts/resource_tool rk-kernel.dtb
rm rk-kernel.dtb
```
This overwrites the `resource.img` with one containing `rk-kernel.dtb` as expected.

---

## RetroArch (`packages/emulators/standalone/retroarch/`)

Created symlink:
```
packages/emulators/standalone/retroarch/sources/RK3566-BSP-RGB20Pro -> RK3566-BSP
```
RetroArch's `post_makeinstall_target` checks for `sources/${DEVICE}/` and exits 1
if missing. The RGB20Pro uses the same RetroArch config as RK3566-BSP.

---

## Device options (`projects/Rockchip/devices/RK3566-BSP-RGB20Pro/options`)

Key settings vs base `RK3566-BSP`:

| Setting | Value | Reason |
|---|---|---|
| `DEVICE_DTB` | `("rk3566-rgb20pro-linux")` | Single DTB for this board |
| `EMULATION_DEVICE` | `"no"` | Skip emulators, faster build |
| `ENABLE_32BIT` | `"false"` | No 32-bit arm build; `config/options` defaults this to `true` which pulls in `lib32` and fails without an arm build |
| `ADDITIONAL_PACKAGES` | GStreamer stack | gstreamer, gst-plugins-base/good/bad/ugly, gst-libav, gstreamer-rockchip |
| `ADDITIONAL_DRIVERS` | `RTL8723DS` | Only the WiFi chip present on this board |

> **`ENABLE_32BIT` pitfall**: `config/options` sets `ENABLE_32BIT="${ENABLE_32BIT-true}"`.
> If not explicitly set to `false`, the `image` virtual package adds `lib32` as a
> dependency. `lib32`'s `makeinstall_target` rsyncs from
> `build.${DISTRO}-${DEVICE}.arm/image/system/` which doesn't exist → rsync exits 23
> → build fails under `set -e`.
