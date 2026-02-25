#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-v1.1.0}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
THIRD_PARTY_DIR="${PACKAGE_ROOT}/third_party/rapidjson"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

ARCHIVE_URL="https://github.com/Tencent/rapidjson/archive/refs/tags/${VERSION}.tar.gz"
ARCHIVE_PATH="${TMP_DIR}/rapidjson.tar.gz"

echo "Downloading ${ARCHIVE_URL}"
curl --fail --location --silent --show-error "${ARCHIVE_URL}" --output "${ARCHIVE_PATH}"
tar -xzf "${ARCHIVE_PATH}" -C "${TMP_DIR}"

EXTRACTED_DIR="$(find "${TMP_DIR}" -maxdepth 1 -type d -name 'rapidjson-*' | head -n 1)"
if [[ -z "${EXTRACTED_DIR}" ]]; then
  echo "Unable to find extracted rapidjson directory." >&2
  exit 1
fi

rm -rf "${THIRD_PARTY_DIR}/include"
mkdir -p "${THIRD_PARTY_DIR}"
cp -R "${EXTRACTED_DIR}/include" "${THIRD_PARTY_DIR}/include"
cp "${EXTRACTED_DIR}/license.txt" "${THIRD_PARTY_DIR}/LICENSE"
printf '%s\n' "${VERSION}" > "${THIRD_PARTY_DIR}/VERSION"

echo "RapidJSON ${VERSION} installed to ${THIRD_PARTY_DIR}/include"
