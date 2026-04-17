#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/demo_racing_fresh_checkout.XXXXXX")"
TMP_HOME="$(mktemp -d "${TMPDIR:-/tmp}/demo_racing_home.XXXXXX")"

cleanup() {
	rm -rf "${TMP_DIR}"
	rm -rf "${TMP_HOME}"
}
trap cleanup EXIT

echo "Preparing fresh checkout copy at ${TMP_DIR}"
rsync -a --exclude '.godot' "${PROJECT_DIR}/" "${TMP_DIR}/"

echo "Smoke test: runtime startup"
HOME="${TMP_HOME}" godot --headless --path "${TMP_DIR}" --quit-after 1

echo "Smoke test: editor import"
HOME="${TMP_HOME}" godot --headless --editor --quit --path "${TMP_DIR}"

echo "Fresh checkout verification passed."
