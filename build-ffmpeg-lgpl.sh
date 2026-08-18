#!/usr/bin/env bash
# =====================================================================
#  Build d'un FFmpeg LGPL (sans x264) avec VideoToolbox, pour le Mac
#  App Store. Produit un binaire "ffmpeg" sans dépendance dylib externe
#  (uniquement les frameworks système), ce qui évite les crashs sandbox.
#
#  Prérequis (une fois) : Xcode Command Line Tools + nasm
#      xcode-select --install
#      brew install nasm pkg-config
#
#  Usage :  bash build-ffmpeg-lgpl.sh
#  Résultat : ./ffmpeg-lgpl/ffmpeg  (à copier dans le bundle, voir plus bas)
# =====================================================================
set -euo pipefail

FFMPEG_VERSION="7.1"          # version stable ; adapter si besoin
BUILD_DIR="$(pwd)/ffmpeg-src"
OUT_DIR="$(pwd)/ffmpeg-lgpl"

mkdir -p "$BUILD_DIR" "$OUT_DIR"
cd "$BUILD_DIR"

if [ ! -d "ffmpeg-${FFMPEG_VERSION}" ]; then
  echo "→ Téléchargement de FFmpeg ${FFMPEG_VERSION}…"
  curl -LO "https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz"
  tar xf "ffmpeg-${FFMPEG_VERSION}.tar.xz"
fi

cd "ffmpeg-${FFMPEG_VERSION}"

echo "→ Configuration (LGPL, sans x264, avec VideoToolbox)…"
# Points clés :
#   PAS de --enable-gpl  → reste LGPL, conforme au Store
#   PAS de --enable-libx264 → aucune bibliothèque GPL
#   --enable-videotoolbox → encodeur H.264 matériel d'Apple (hors licence)
#   Aucune lib externe activée → binaire autonome (pas de dylib /usr/local)
#   Les décodeurs ProRes / DNxHD / HEVC / MXF sont dans le cœur LGPL (inclus)
./configure \
  --prefix="$OUT_DIR" \
  --disable-gpl \
  --disable-nonfree \
  --enable-videotoolbox \
  --enable-audiotoolbox \
  --disable-doc \
  --disable-ffplay \
  --disable-debug \
  --enable-static \
  --disable-shared \
  --arch=arm64 \
  --enable-cross-compile 2>/dev/null || \
./configure \
  --prefix="$OUT_DIR" \
  --disable-gpl \
  --disable-nonfree \
  --enable-videotoolbox \
  --enable-audiotoolbox \
  --disable-doc \
  --disable-ffplay \
  --disable-debug \
  --enable-static \
  --disable-shared

echo "→ Compilation (peut prendre quelques minutes)…"
make -j"$(sysctl -n hw.ncpu)"
make install

echo ""
echo "=== Vérifications ==="
echo "→ Dépendances externes (doit ne montrer QUE des libs système /usr/lib, /System) :"
otool -L "$OUT_DIR/bin/ffmpeg" | grep -v "$OUT_DIR" || true
echo ""
echo "→ Présence de l'encodeur VideoToolbox (doit lister h264_videotoolbox) :"
"$OUT_DIR/bin/ffmpeg" -hide_banner -encoders 2>/dev/null | grep videotoolbox || echo "  ⚠ VideoToolbox absent — vérifie la config"
echo ""
echo "✓ Binaire prêt : $OUT_DIR/bin/ffmpeg"
echo "  Copie-le à la racine de ton projet sous  resources/ffmpeg  (voir package.json)."
