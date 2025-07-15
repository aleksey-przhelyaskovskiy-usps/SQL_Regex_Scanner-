#!/bin/bash
set -e
RULES_FILE="$1"
ZIP_FILE="$2"
OUTPUT_FILE="${3:-scan_report.json}"
WORK_DIR="sql_scan_tmp"

if [[ -z "$RULES_FILE" || -z "$ZIP_FILE" ]]; then
  echo "Usage: $0 <rules_file> <zip_file> [output_file]"
  exit 2
fi

if ! command -v unzip >/dev/null; then
  echo "❌ 'unzip' is required but not found"
  exit 3
fi

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
unzip -qq "$ZIP_FILE" -d "$WORK_DIR"

MATCHES=()
FOUND=0

echo "🔍 Scanning SQL files using rules from $RULES_FILE..."

while IFS= read -r rule || [[ -n "$rule" ]]; do
  [[ "$rule" =~ ^#.*$ || -z "$rule" ]] && continue
  echo "➡️  Rule: $rule"

  while IFS= read -r -d '' file; do
    LINENUM=0
    while IFS= read -r line || [[ -n "$line" ]]; do
      ((LINENUM++))
      if [[ "$line" =~ $rule ]]; then
        echo "❗ Match in $file:$LINENUM — $line"
        FOUND=1
        MATCHES+=("{\"file\":\"$file\",\"line\":$LINENUM,\"rule\":\"${rule//\"/\\\"}\"}")
      fi
    done < "$file"
  done < <(find "$WORK_DIR" -type f -name '*.sql' -print0)
done < "$RULES_FILE"

{
  echo "["
  printf "  %s\n" "$(IFS=,; echo "${MATCHES[*]}")"
  echo "]"
} > "$OUTPUT_FILE"

echo "📄 Report written to: $OUTPUT_FILE"

if [[ "$FOUND" -eq 1 ]]; then
  echo "❌ Violations found"
  exit 1
else
  echo "✅ No matches found"
  exit 0
fi
