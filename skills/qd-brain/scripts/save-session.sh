#!/bin/bash
# save-session.sh — Lưu một entry vào session hiện tại
# Usage: ./save-session.sh "Tiêu đề" "Nội dung"
# Ví dụ: ./save-session.sh "Decision" "Dùng Redis cho cache vì latency thấp hơn"
 
set -e
 
TITLE="${1:-Update}"
CONTENT="${2:-}"
TIME=$(date '+%H:%M')
DOC_DIR=".doc"
CURRENT="$DOC_DIR/session/current.md"
 
if [ ! -f "$CURRENT" ]; then
  echo "❌ Không tìm thấy $CURRENT — chạy /qd-brain trước"
  exit 1
fi
 
echo "" >> "$CURRENT"
echo "- $TIME — **$TITLE**: $CONTENT" >> "$CURRENT"
 
echo "✅ Đã lưu vào session: [$TIME] $TITLE"
 