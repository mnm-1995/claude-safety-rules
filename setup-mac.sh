#!/bin/bash
# Claude Code 安全ガイドライン 自動取得セットアップ（Mac用）
# 実行方法: bash setup-mac.sh

RULE_URL="https://raw.githubusercontent.com/mnm-1995/claude-safety-rules/main/CLAUDE.md"
TARGET="$HOME/.claude/CLAUDE.md"

echo "===================================="
echo " Claude Code 安全ルール セットアップ"
echo "===================================="
echo ""

# ~/.claude フォルダを作成
mkdir -p "$HOME/.claude"

# 最新のCLAUDE.mdを取得
echo "▶ 安全ルールを取得しています..."
curl -s "$RULE_URL" -o "$TARGET"

if [ $? -eq 0 ]; then
  echo "✅ 取得完了しました"
else
  echo "❌ 取得に失敗しました。インターネット接続を確認してください"
  exit 1
fi

# 毎朝9時に自動更新するcronを登録
CRON_JOB="0 9 * * * curl -s $RULE_URL -o $TARGET"
( crontab -l 2>/dev/null | grep -v "claude-safety-rules"; echo "$CRON_JOB" ) | crontab -

echo "✅ 毎朝9時に自動更新する設定が完了しました"
echo ""
echo "===================================="
echo " セットアップ完了！"
echo " Claude Codeを再起動すると有効になります"
echo "===================================="
