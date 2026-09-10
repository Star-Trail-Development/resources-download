#!/bin/bash
set -euo pipefail

TARGET_DIRS=("mods" "resourcepacks" "shaderpacks")
TOTAL=0
EMPTY_URL_TOTAL=0

for dir in "${TARGET_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "[skip] $dir: directory not found"
    continue
  fi

  while IFS= read -r -d '' file; do
    echo "  $file"

    # side → 'both'（匹配 side = '' / 'client' / 'server' / 'both'）
    sed -i "s/^side = '.*'/side = 'both'/" "$file"

    # 检测并移除空的 url 字段（mode = 'metadata:curseforge' 时 url 恒为空，删除后由 mode 决定下载地址）
    if grep -qE "^[[:space:]]*url[[:space:]]*=[[:space:]]*''[[:space:]]*$" "$file"; then
      sed -i -E "/^[[:space:]]*url[[:space:]]*=[[:space:]]*''[[:space:]]*$/d" "$file"
      echo "    [fix] removed empty url"
      EMPTY_URL_TOTAL=$((EMPTY_URL_TOTAL + 1))
    fi

    TOTAL=$((TOTAL + 1))
  done < <(find "$dir" -name "*.pw.toml" -type f -print0)
done

echo ""
echo "Done. Processed $TOTAL file(s), removed $EMPTY_URL_TOTAL empty url line(s)."
