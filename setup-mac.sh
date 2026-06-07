#!/bin/bash
# Claude Code 安全ガイドライン セットアップ（Mac用）
# 実行方法: ターミナルで bash setup-mac.sh を実行

RULE_URL="https://raw.githubusercontent.com/mnm-1995/claude-safety-rules/main/CLAUDE.md"
TARGET="$HOME/.claude/CLAUDE.md"
SHELL_RC="$HOME/.zshrc"

echo "===================================="
echo " Claude Code 安全ルール セットアップ"
echo "===================================="
echo ""

# ~/.claude フォルダを作成
mkdir -p "$HOME/.claude"

# 最新のCLAUDE.mdを今すぐ取得
echo "▶ 安全ルールを取得しています..."
curl -s "$RULE_URL" -o "$TARGET"

if [ $? -eq 0 ]; then
  echo "✅ 取得完了しました"
else
  echo "❌ 取得に失敗しました。インターネット接続を確認してください"
  exit 1
fi

# claude コマンドを起動するたびに最新版を取得するラッパーを登録
WRAPPER=$(cat <<'EOF'

# Claude Code 起動時に安全ルールを自動更新
claude() {
  curl -s "https://raw.githubusercontent.com/mnm-1995/claude-safety-rules/main/CLAUDE.md" \
    -o "$HOME/.claude/CLAUDE.md" 2>/dev/null
  command claude "$@"
}
EOF
)

# すでに登録済みでなければ追加
if ! grep -q "claude-safety-rules" "$SHELL_RC" 2>/dev/null; then
  echo "$WRAPPER" >> "$SHELL_RC"
  echo "✅ Claude Code起動時に自動更新する設定が完了しました"
else
  echo "✅ 自動更新の設定はすでに済んでいます"
fi

echo ""
echo "===================================="
echo " セットアップ完了！"
echo " ターミナルを再起動してから claude を起動してください"
echo "===================================="
