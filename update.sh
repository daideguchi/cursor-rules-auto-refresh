#!/bin/bash

# Cursor Rules Update Script
# Usage: curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/update.sh | bash

set -e

REPO_URL="https://github.com/your-org/cursor-rules.git"
TEMP_DIR=$(mktemp -d)
BACKUP_DIR=".cursor/rules.backup-$(date +%Y%m%d-%H%M%S)"

echo "🔄 Updating Cursor Development Rules..."

# 既存ルールの確認
if [[ ! -d ".cursor/rules" ]]; then
    echo "❌ No existing Cursor rules found. Use install script first:"
    echo "   curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash"
    exit 1
fi

# バックアップ作成
echo "📦 Creating backup at $BACKUP_DIR..."
cp -r .cursor/rules $BACKUP_DIR

# ルールリポジトリをクローン
echo "📥 Downloading latest rules..."
git clone --depth 1 $REPO_URL $TEMP_DIR >/dev/null 2>&1

# 更新確認
echo "🤔 Select update option:"
echo "1) Update all rules (overwrite customizations)"
echo "2) Update only core rules (preserve dev-rules customizations)"
echo "3) Cancel update"
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo "🔄 Updating all rules..."
        rm -rf .cursor/rules
        mkdir -p .cursor/rules/dev-rules
        cp -r $TEMP_DIR/templates/* .cursor/rules/
        echo "✅ All rules updated"
        ;;
    2)
        echo "🔄 Updating core rules only..."
        cp $TEMP_DIR/templates/globals.mdc .cursor/rules/
        cp $TEMP_DIR/templates/todo.mdc .cursor/rules/
        if [[ -f "$TEMP_DIR/templates/uiux.mdc" ]]; then
            cp $TEMP_DIR/templates/uiux.mdc .cursor/rules/ 2>/dev/null || true
        fi
        echo "✅ Core rules updated, dev-rules preserved"
        ;;
    3)
        echo "❌ Update cancelled"
        rm -rf $BACKUP_DIR
        rm -rf $TEMP_DIR
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Update cancelled."
        rm -rf $BACKUP_DIR
        rm -rf $TEMP_DIR
        exit 1
        ;;
esac

# クリーンアップ
rm -rf $TEMP_DIR

echo ""
echo "✅ Cursor rules updated successfully!"
echo "📦 Backup saved to: $BACKUP_DIR"
echo "🔍 Review changes and test your setup"
echo ""
echo "💡 To restore from backup if needed:"
echo "   rm -rf .cursor/rules && mv $BACKUP_DIR .cursor/rules" 