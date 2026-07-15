#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"

source_dir="$package_root/third_party/ffmpeg/source/ffmpeg"
output_dir="$package_root/third_party/ffmpeg/linux"
build_dir_name=".build-minimal-linux"
ffmpeg_ref="n8.0.1"
docker_image="debian:bookworm-slim"
docker_platform="linux/amd64"
jobs=""
inside_container=0
use_docker=1

usage() {
  cat <<'EOF'
Build the vendored Linux FFmpeg SDK for speech_utils.

Usage:
  packages/speech_utils/tool/build_linux_ffmpeg_sdk.sh [options]

Options:
  --source-dir PATH       FFmpeg source checkout. Defaults to third_party/ffmpeg/source/ffmpeg.
  --output-dir PATH       SDK output. Defaults to third_party/ffmpeg/linux.
  --ffmpeg-ref REF        FFmpeg git tag/branch/commit to clone when source is missing. Default: n8.0.1.
  --docker-image IMAGE    Linux image used for host builds. Default: debian:bookworm-slim.
  --docker-platform PLAT  Docker platform. Default: linux/amd64.
  --jobs N               Parallel make jobs. Defaults to nproc inside the build environment.
  --no-docker            Build directly on this host. Requires Linux build dependencies.
  --help                 Show this help.

The build output layout is:
  third_party/ffmpeg/linux/include/{libavcodec,libavformat,libavutil,libswresample}
  third_party/ffmpeg/linux/lib/libavcodec.so*
  third_party/ffmpeg/linux/lib/libavformat.so*
  third_party/ffmpeg/linux/lib/libavutil.so*
  third_party/ffmpeg/linux/lib/libswresample.so*
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-dir)
      source_dir="$2"
      shift 2
      ;;
    --output-dir)
      output_dir="$2"
      shift 2
      ;;
    --ffmpeg-ref)
      ffmpeg_ref="$2"
      shift 2
      ;;
    --docker-image)
      docker_image="$2"
      shift 2
      ;;
    --docker-platform)
      docker_platform="$2"
      shift 2
      ;;
    --jobs)
      jobs="$2"
      shift 2
      ;;
    --no-docker)
      use_docker=0
      shift
      ;;
    --inside-container)
      inside_container=1
      use_docker=0
      shift
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

absolute_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s\n' "$(pwd)/$path"
  fi
}

source_dir="$(absolute_path "$source_dir")"
output_dir="$(absolute_path "$output_dir")"

if [[ "$use_docker" -eq 1 && "$(uname -s)" != "Linux" ]]; then
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required to build the Linux SDK from non-Linux hosts." >&2
    exit 90
  fi

  repo_root="$(cd "$package_root/../.." && pwd)"
  container_package_root="/work/packages/speech_utils"
  container_source_dir="$container_package_root/third_party/ffmpeg/source/ffmpeg"
  container_output_dir="$container_package_root/third_party/ffmpeg/linux"

  docker run --rm \
    --platform "$docker_platform" \
    -v "$repo_root:/work" \
    -w "$container_package_root" \
    "$docker_image" \
    bash -lc "bash ./tool/build_linux_ffmpeg_sdk.sh --inside-container --source-dir '$container_source_dir' --output-dir '$container_output_dir' --ffmpeg-ref '$ffmpeg_ref' ${jobs:+--jobs $jobs}"
  exit 0
fi

if [[ "$inside_container" -eq 1 ]]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    build-essential \
    pkg-config \
    make \
    nasm \
    yasm
  rm -rf /var/lib/apt/lists/*
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required." >&2
  exit 91
fi
if ! command -v make >/dev/null 2>&1; then
  echo "make is required." >&2
  exit 92
fi

if [[ -z "$jobs" ]]; then
  if command -v nproc >/dev/null 2>&1; then
    jobs="$(nproc)"
  else
    jobs="1"
  fi
fi

if [[ ! -d "$source_dir/.git" ]]; then
  rm -rf "$source_dir"
  mkdir -p "$(dirname "$source_dir")"
  git clone --depth 1 --branch "$ffmpeg_ref" https://github.com/ffmpeg/ffmpeg.git "$source_dir"
fi

if [[ ! -x "$source_dir/configure" ]]; then
  echo "FFmpeg source directory does not contain configure script: $source_dir/configure" >&2
  exit 93
fi

build_dir="$output_dir/$build_dir_name"
build_log="$build_dir/ffmpeg-build.log"

mkdir -p "$output_dir"
rm -rf "$output_dir/include" "$output_dir/lib" "$output_dir/bin" "$output_dir/share" "$build_dir"
mkdir -p "$build_dir"

configure_args=(
  "--prefix=$output_dir"
  "--enable-shared"
  "--disable-static"
  "--disable-programs"
  "--disable-doc"
  "--disable-debug"
  "--disable-optimizations"
  "--disable-everything"
  "--disable-network"
  "--disable-autodetect"
  "--disable-avdevice"
  "--disable-avfilter"
  "--disable-swscale"
  "--enable-small"
  "--enable-pic"
  "--enable-pthreads"
  "--enable-avcodec"
  "--enable-avformat"
  "--enable-avutil"
  "--enable-swresample"
  "--enable-encoder=aac"
  "--enable-decoder=pcm_s16le,aac,mp3"
  "--enable-parser=aac,mpegaudio"
  "--enable-demuxer=wav,mov,mp3,aac"
  "--enable-muxer=ipod,adts"
  "--enable-protocol=file"
  "--disable-iconv"
  "--disable-zlib"
)

(
  set -x
  cd "$build_dir"
  "$source_dir/configure" "${configure_args[@]}"
  make -j"$jobs"
  make install
  rm -rf "$output_dir/share" "$output_dir/bin"
) 2>&1 | tee "$build_log"

ffmpeg_commit="$(git -C "$source_dir" rev-parse HEAD)"
cat > "$output_dir/BUILD-METADATA.txt" <<EOF
ffmpeg profile: audio-only minimal
toolchain: gcc
threads: pthreads
ffmpeg_ref: $ffmpeg_ref
ffmpeg_commit: $ffmpeg_commit
docker_image: $docker_image
docker_platform: $docker_platform
configure_args:
$(printf '  %s\n' "${configure_args[@]}")
EOF

bash "$script_dir/verify_linux_ffmpeg_bundle.sh" --ffmpeg-linux-dir "$output_dir"
rm -rf "$build_dir"

echo "FFmpeg Linux SDK build complete."
echo "Source: $source_dir"
echo "Output: $output_dir"
