#!/bin/bash

# Cursor Rules Quick Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash

set -e

REPO_URL="https://github.com/your-org/cursor-rules.git"
TEMP_DIR=$(mktemp -d)
PROJECT_NAME=$(basename "$(pwd)")

echo "🚀 Installing Cursor Development Rules..."
echo "📁 Project: $PROJECT_NAME"

# プロジェクトタイプの自動判定
detect_project_type() {
    if [[ -f "package.json" ]]; then
        if grep -q "react\|vue\|angular" package.json 2>/dev/null; then
            echo "web-application"
        elif grep -q "express\|fastify\|koa" package.json 2>/dev/null; then
            echo "api-service"
        else
            echo "library"
        fi
    elif [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
        echo "python-app"
    elif [[ -f "go.mod" ]]; then
        echo "go-service"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust-app"
    else
        echo "general"
    fi
}

PROJECT_TYPE=$(detect_project_type)
echo "🔍 Detected project type: $PROJECT_TYPE"

# ルールリポジトリをクローン
echo "📥 Downloading rules..."
git clone --depth 1 $REPO_URL $TEMP_DIR >/dev/null 2>&1

# ディレクトリ作成
mkdir -p .cursor/rules/dev-rules

# コアルールをコピー
echo "📋 Installing core rules..."
cp $TEMP_DIR/templates/globals.mdc .cursor/rules/
cp $TEMP_DIR/templates/todo.mdc .cursor/rules/

# プロジェクトタイプ別ルールの適用
echo "🛠️  Applying project-specific rules..."
case $PROJECT_TYPE in
    "web-application")
        cp $TEMP_DIR/templates/dev-rules/coding-standards.mdc .cursor/rules/dev-rules/
        cp $TEMP_DIR/templates/dev-rules/git-workflow.mdc .cursor/rules/dev-rules/
        cp $TEMP_DIR/templates/dev-rules/testing-guidelines.mdc .cursor/rules/dev-rules/
        cp $TEMP_DIR/templates/uiux.mdc .cursor/rules/
        ;;
    "api-service"|"python-app"|"go-service"|"rust-app")
        cp $TEMP_DIR/templates/dev-rules/coding-standards.mdc .cursor/rules/dev-rules/
        cp $TEMP_DIR/templates/dev-rules/git-workflow.mdc .cursor/rules/dev-rules/
        cp $TEMP_DIR/templates/dev-rules/testing-guidelines.mdc .cursor/rules/dev-rules/
        ;;
    "library")
        cp $TEMP_DIR/templates/dev-rules/coding-standards.mdc .cursor/rules/dev-rules/
        cp $TEMP_DIR/templates/dev-rules/git-workflow.mdc .cursor/rules/dev-rules/
        cp $TEMP_DIR/templates/dev-rules/testing-guidelines.mdc .cursor/rules/dev-rules/
        ;;
    *)
        cp $TEMP_DIR/templates/dev-rules/*.mdc .cursor/rules/dev-rules/ 2>/dev/null || true
        ;;
esac

# globals.mdcにプロジェクト情報を追加
sed -i.bak "s/{{instructions}}/Project: $PROJECT_NAME ($PROJECT_TYPE)/g" .cursor/rules/globals.mdc 2>/dev/null || \
    sed -i "s/{{instructions}}/Project: $PROJECT_NAME ($PROJECT_TYPE)/g" .cursor/rules/globals.mdc 2>/dev/null || true
rm -f .cursor/rules/globals.mdc.bak

# @todo.mdファイルの生成
echo "📝 Creating task management file..."
cat > @todo.md << EOF
# $PROJECT_NAME - タスク管理

## 現在のタスク

### 🔴 緊急
- [ ] 未着手のタスクなし

### 🟡 重要
- [ ] 未着手のタスクなし

### 🟢 通常
- [ ] 未着手のタスクなし

### ⚪ 低優先
- [ ] 未着手のタスクなし

## 進行中のタスク

### [~] 進行中
- [~] プロジェクト初期設定
  - [x] Cursor rules の適用
  - [ ] 依存関係の設定
  - [ ] 基本的な設定ファイルの作成

## 完了したタスク

### [x] 完了
- [x] プロジェクト作成
- [x] 開発ルールの適用

## 課題・ブロッカー

### [!] 問題あり
- 現在問題なし

## メモ・備考

- このファイルは機能実装後に随時更新する
- 新しい要件や問題が発見された場合は即座に追加する
- タスクの優先順位は状況に応じて調整する

## 最終更新日
$(date +%Y-%m-%d)
EOF

# .gitignoreに追加（存在する場合）
if [[ -f ".gitignore" ]]; then
    if ! grep -q "# Cursor rules backup" .gitignore; then
        echo "" >> .gitignore
        echo "# Cursor rules backup" >> .gitignore
        echo ".cursor/rules.backup" >> .gitignore
    fi
fi

# クリーンアップ
rm -rf $TEMP_DIR

# Install auto-refresh system
echo "🔧 Setting up auto-refresh system..."
curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/auto-rules-refresh.sh > .cursor/rules/auto-rules-refresh.sh 2>/dev/null || true
chmod +x .cursor/rules/auto-rules-refresh.sh 2>/dev/null || true

# Install git hooks system
echo "🔗 Setting up Git hooks..."
curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/git-hooks-setup.sh > .cursor/rules/git-hooks-setup.sh 2>/dev/null || true
chmod +x .cursor/rules/git-hooks-setup.sh 2>/dev/null || true

# Apply git hooks if in git repository
if [[ -d ".git" ]]; then
    bash .cursor/rules/git-hooks-setup.sh install 2>/dev/null || true
    echo "✅ Git hooks installed"
fi

# Apply Cursor IDE settings
echo "⚙️  Optimizing Cursor IDE settings..."
mkdir -p .cursor
if [[ ! -f ".cursor/settings.json" ]]; then
    curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/cursor-settings-template.json > .cursor/settings.json 2>/dev/null || true
    echo "✅ Cursor IDE settings applied"
else
    echo "ℹ️  Cursor settings file exists, skipping"
fi

echo ""
echo "✅ Cursor development rules installed successfully!"
echo ""
echo "📁 Files created:"
echo "   - .cursor/rules/ (development rules)"
echo "   - @todo.md (task management)"
echo "   - .cursor/settings.json (IDE settings)"
echo "   - Git hooks (if in git repository)"
echo ""
echo "🚀 Quick start commands:"
echo "   cursor-auto on       # Enable auto-refresh"
echo "   cursor-remind        # Quick rules reminder"
echo "   cursor-start         # Initialize dev session"
echo ""
echo "🔄 To update rules later:"
echo "   curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/update.sh | bash"
echo ""
echo "📖 Next steps:"
echo "   1. Open project in Cursor IDE"
echo "   2. Enable auto-refresh with 'cursor-auto on'"
echo "   3. Start coding with enhanced AI assistance!"
echo ""
echo "💡 Pro Tips:"
echo "   • Git hooks will remind you about rules automatically"
echo "   • Auto-refresh keeps rules fresh every 15 minutes"
echo "   • Use 'cursor-remind' anytime you forget the rules" 