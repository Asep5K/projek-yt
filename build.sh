#!/usr/bin/env bash
set -euo pipefail

OUTPUT="yt-termux.sh"
SRC=(
  lib/variable.sh
  lib/ascii.sh
  lib/utils.sh
  lib/install.sh
  lib/download.sh
  lib/play.sh
  lib/menus.sh
  lib/main.sh
)

echo "🔍 Checking source files..."
for file in "${SRC[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "❌ Missing source file: $file"
    exit 1
  fi
done

echo "🔨 Building $OUTPUT ..."
cat "${SRC[@]}" > "$OUTPUT"
chmod +x "$OUTPUT"
echo "✅ Build completed: $OUTPUT"
