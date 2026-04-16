#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/demo_tps_art"

if command -v godot >/dev/null 2>&1; then
  # Ensure imported artifacts exist before running the project headless.
  godot --headless --editor --quit --path "${PROJECT_DIR}"
  godot --headless --path "${PROJECT_DIR}" --quit-after 1
  exit 0
fi

cat <<'EOF'
当前环境找不到 `godot` 命令，无法执行 headless 检查。

建议先安装 Godot CLI（Homebrew）：
  brew install --cask godot
  godot --version

然后再运行：
  ./demo_tps_art/run_headless_check.sh
EOF

exit 127

