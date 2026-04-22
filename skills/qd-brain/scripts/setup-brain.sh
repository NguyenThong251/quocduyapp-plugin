#!/bin/bash
# setup-brain.sh — Khởi tạo hoặc verify .doc/ structure
# Chạy từ root dự án

set -e

DOC_DIR=".doc"
DATE=$(date '+%Y-%m-%d')
DATETIME=$(date '+%Y-%m-%d_%H-%M')

echo "🧠 QD-Brain: Kiểm tra cấu trúc .doc/..."

# Create directories if not exist
mkdir -p "$DOC_DIR/session/history"
mkdir -p "$DOC_DIR/plan/active"
mkdir -p "$DOC_DIR/plan/completed"
mkdir -p "$DOC_DIR/rules"
mkdir -p "$DOC_DIR/knowledge/features"
mkdir -p "$DOC_DIR/knowledge/issues"
mkdir -p "$DOC_DIR/init"

echo "✅ Thư mục .doc/ đã sẵn sàng"

# Check which files exist
MISSING=()

[ ! -f "$DOC_DIR/CLAUDE.md" ] && MISSING+=("CLAUDE.md")
[ ! -f "$DOC_DIR/session/current.md" ] && MISSING+=("session/current.md")
[ ! -f "$DOC_DIR/session/handoff.md" ] && MISSING+=("session/handoff.md")
[ ! -f "$DOC_DIR/rules/git.md" ] && MISSING+=("rules/git.md")
[ ! -f "$DOC_DIR/rules/naming.md" ] && MISSING+=("rules/naming.md")
[ ! -f "$DOC_DIR/rules/code-style.md" ] && MISSING+=("rules/code-style.md")
[ ! -f "$DOC_DIR/knowledge/architecture.md" ] && MISSING+=("knowledge/architecture.md")

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "✅ Tất cả files đã tồn tại"
else
  echo "⚠️  Files còn thiếu:"
  for f in "${MISSING[@]}"; do
    echo "   - $DOC_DIR/$f"
  done
  echo "→ Claude sẽ tạo các files còn thiếu"
fi

# Print current structure
echo ""
echo "📁 Cấu trúc .doc/ hiện tại:"
find "$DOC_DIR" -type f | sort | sed 's/^/   /'

echo ""
echo "🧠 Brain status: READY"