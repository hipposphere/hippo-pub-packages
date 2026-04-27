#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
ffmpeg_linux_dir="$package_root/third_party/ffmpeg/linux"

usage() {
  cat <<'EOF'
Validate the vendored Linux FFmpeg SDK for speech_utils.

Usage:
  packages/speech_utils/tool/verify_linux_ffmpeg_bundle.sh [--ffmpeg-linux-dir PATH]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ffmpeg-linux-dir)
      ffmpeg_linux_dir="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

if [[ "$ffmpeg_linux_dir" != /* ]]; then
  ffmpeg_linux_dir="$(pwd)/$ffmpeg_linux_dir"
fi

include_dir="$ffmpeg_linux_dir/include"
lib_dir="$ffmpeg_linux_dir/lib"

required_headers=(
  "libavcodec/avcodec.h"
  "libavformat/avformat.h"
  "libavutil/avutil.h"
  "libswresample/swresample.h"
)
required_libs=(
  "avcodec"
  "avformat"
  "avutil"
  "swresample"
)

[[ -d "$include_dir" ]] || { echo "Missing include directory: $include_dir" >&2; exit 1; }
[[ -d "$lib_dir" ]] || { echo "Missing lib directory: $lib_dir" >&2; exit 1; }

for header in "${required_headers[@]}"; do
  [[ -f "$include_dir/$header" ]] || { echo "Missing header: $include_dir/$header" >&2; exit 1; }
done

for lib in "${required_libs[@]}"; do
  [[ -e "$lib_dir/lib$lib.so" ]] || { echo "Missing linker library: $lib_dir/lib$lib.so" >&2; exit 1; }
  shopt -s nullglob
  matches=("$lib_dir/lib$lib.so."*)
  shopt -u nullglob
  if [[ "${#matches[@]}" -eq 0 ]]; then
    echo "Missing versioned runtime library matching: $lib_dir/lib$lib.so.*" >&2
    exit 1
  fi
done

if command -v ldd >/dev/null 2>&1; then
  issues=()
  shopt -s nullglob
  for so in "$lib_dir"/lib{avcodec,avformat,avutil,swresample}.so.*; do
    if ! LD_LIBRARY_PATH="$lib_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" ldd "$so" >/tmp/speech_utils_linux_ffmpeg_ldd.txt 2>/dev/null; then
      issues+=("ldd failed for $so")
      continue
    fi
    if grep -Eq "not found" /tmp/speech_utils_linux_ffmpeg_ldd.txt; then
      issues+=("unresolved runtime dependency in $so")
    fi
  done
  shopt -u nullglob
  if [[ "${#issues[@]}" -gt 0 ]]; then
    printf '%s\n' "${issues[@]}" >&2
    exit 1
  fi
fi

echo "FFmpeg Linux bundle validation passed."
echo "include: $include_dir"
echo "lib:     $lib_dir"
