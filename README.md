# marey-ffmpeg

Source code and build script for the FFmpeg binary bundled with
[Marey](https://apps.apple.com/app/id6802018294), a macOS app for synchronised
video comparison and footage review.

This repository exists to satisfy the source distribution requirement of the
**GNU Lesser General Public License, version 2.1**, under which FFmpeg is
distributed.

---

## What is in here

| | |
|---|---|
| **FFmpeg version** | 7.1 |
| **Modified?** | No. The sources are the official upstream release, unchanged. |
| **How it is used** | Marey runs `ffmpeg` as a **separate process**. It is not linked into the application. |
| **License** | LGPL 2.1 or later. No GPL or non-free components are enabled. |

- `build-ffmpeg-lgpl.sh` — the exact script used to produce the binary shipped
  with Marey. It downloads the official FFmpeg source archive, configures it,
  and builds a self-contained `arm64` binary with no external dynamic library
  dependencies.
- **[Releases](../../releases)** — the complete, unmodified FFmpeg source
  archive corresponding to the binary shipped with each version of Marey.

## Getting the sources

Download `ffmpeg-7.1.tar.xz` from the
[Releases page](../../releases), or directly from the official project:

```
curl -LO https://ffmpeg.org/releases/ffmpeg-7.1.tar.xz
```

Both are byte-for-byte identical. The archive attached to the release is kept
here so that the exact sources remain available alongside the binary that was
built from them, for as long as Marey is distributed.

## Build configuration

The binary is built with the following options. The two that matter for
licensing are `--disable-gpl` and `--disable-nonfree`: no GPL-licensed or
non-redistributable component is compiled in.

```
./configure \
  --disable-gpl \
  --disable-nonfree \
  --enable-videotoolbox \
  --enable-audiotoolbox \
  --disable-doc \
  --disable-ffplay \
  --disable-debug \
  --enable-static \
  --disable-shared \
  --arch=arm64
```

H.264 encoding uses Apple's **VideoToolbox**, which is part of macOS and is not
covered by FFmpeg's licence. `libx264` is deliberately **not** included, as it
is GPL-licensed. The ProRes, DNxHD, HEVC and MXF decoders that Marey relies on
are part of the LGPL core and require no additional libraries.

To reproduce the build:

```
bash build-ffmpeg-lgpl.sh
```

Requires the Xcode Command Line Tools and `nasm`
(`brew install nasm pkg-config`).

## Licensing

FFmpeg is copyright its authors and is distributed under the GNU Lesser General
Public License, version 2.1 or later. The full licence text is included in the
source archive as `COPYING.LGPLv2.1`, and is also available at
<https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html>.

Marey neither modifies FFmpeg nor links against it: the binary is invoked as a
separate executable. The build script in this repository is provided as-is so
that anyone can verify or reproduce the binary that ships with the app.

Marey itself is a separate, proprietary work and is not covered by the LGPL.

## Contact

Questions about this repository or about obtaining the sources:
**support@hccrea.com**
