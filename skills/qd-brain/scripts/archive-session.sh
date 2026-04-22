session.sh
#!/bin/bash
# archive-session.sh — Archive session hiện tại và tạo handoff
# Chạy cuối session trước khi đóng máy
 
set -e
 
DOC_DIR=".doc"
DATETIME=$(date '+%Y-%m-%d_%H-%M')
CURRENT="$DOC_DIR/session/current.md"
ARCHIVE="$DOC_DIR/session/history/$DATETIME.md"
 
if [ ! -f "$CURRENT" ]; then
  echo "❌ Không tìm thấy $CURRENT"
  exit 1
fi
 
# Archive current session
cp "$CURRENT" "$ARCHIVE"
echo "✅ Archived: $ARCHIVE"
 
# Reset current session
DATE=$(date '+%Y-%m-%d %H:%M')
cat > "$CURRENT" << EOF
# Current Session — $DATE
 
## Objectives
- [ ] (chưa set)
 
## Timeline
- $(date '+%H:%M') — Session mới bắt đầu
 
## Active Plan
(chưa có)
 
## Running Notes
 
EOF
 
echo "✅ Reset session/current.md"
echo ""
echo "⚠️  Đừng quên cập nhật session/handoff.md cho session tiếp theo!"
echo "   File: $DOC_DIR/session/handoff.md"
 