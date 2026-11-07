#!/usr/bin/env bash
# Publish the MiDaS weights as the GitHub Release asset the manifest's `remoteUrl` points at.
#
#   scripts/release.sh            # verify only: download upstream, check size + sha256 against manifest.json
#   scripts/release.sh --publish  # verify, then create release v<manifest.version> with midas.onnx
#
# Needs: curl, sha256sum, node; --publish also needs an authenticated `gh` with write access.
# The checksum and byteSize live in manifest.json (committed, and covered by the package signature);
# this script never rewrites them, it only refuses to publish bytes that do not match.
set -euo pipefail
cd "$(dirname "$0")/.."

UPSTREAM="https://huggingface.co/julienkay/sentis-MiDaS/resolve/main/onnx/midas_v21_small_256.onnx"
ASSET="midas.onnx"
VERSION="$(node -p 'require("./manifest.json").version')"
WANT_SUM="$(node -p 'require("./manifest.json").assets[0].checksum.replace(/^sha256-/, "")')"
WANT_SIZE="$(node -p 'require("./manifest.json").assets[0].byteSize')"
WANT_URL="https://github.com/HereLiesAz/azphalt-midas/releases/download/v${VERSION}/${ASSET}"
[ "$(node -p 'require("./manifest.json").assets[0].remoteUrl')" = "$WANT_URL" ] \
  || { echo "manifest remoteUrl does not point at v${VERSION}/${ASSET}" >&2; exit 1; }

out="$(mktemp -d)"; trap 'rm -rf "$out"' EXIT
curl --fail --location --silent --show-error "$UPSTREAM" --output "$out/$ASSET"
got_size="$(stat -c%s "$out/$ASSET")"
got_sum="$(sha256sum "$out/$ASSET" | cut -d' ' -f1)"
[ "$got_size" = "$WANT_SIZE" ] || { echo "size $got_size != manifest $WANT_SIZE" >&2; exit 1; }
[ "$got_sum" = "$WANT_SUM" ]   || { echo "sha256 $got_sum != manifest $WANT_SUM" >&2; exit 1; }
echo "ok: $ASSET $got_size bytes sha256-$got_sum matches manifest"

if [ "${1:-}" = "--publish" ]; then
  gh release create "v${VERSION}" "$out/$ASSET" --repo HereLiesAz/azphalt-midas \
    --title "MiDaS v${VERSION}" \
    --notes "MiDaS v2.1 small (256x256, ONNX opset 15, float32). Unmodified copy of ${UPSTREAM} (MIT). sha256 ${got_sum}."
fi
