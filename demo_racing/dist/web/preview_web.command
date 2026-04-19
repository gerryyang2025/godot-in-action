#!/bin/zsh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${1:-8060}"
URL="http://localhost:${PORT}"

if ! command -v python3 >/dev/null 2>&1; then
	echo "python3 is required to preview this web export."
	exit 1
fi

echo "Starting local preview server..."
echo "Root: ${SCRIPT_DIR}"
echo "URL:  ${URL}"
echo "Press Ctrl+C to stop."

if command -v open >/dev/null 2>&1; then
	(
		sleep 1
		open "${URL}" >/dev/null 2>&1 || true
	) &
fi

exec python3 -m http.server "${PORT}" --directory "${SCRIPT_DIR}"
