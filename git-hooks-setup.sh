#!/bin/bash

# Git Hooks Setup for Cursor Rules
# Git操作時に自動でルール確認を行うシステム

set -e

HOOKS_DIR=".git/hooks"
RULES_DIR=".cursor/rules"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Git リポジトリ確認
check_git_repo() {
    if [[ ! -d ".git" ]]; then
        echo -e "${RED}❌ Not a git repository${NC}"
        exit 1
    fi
    
    if [[ ! -d "$RULES_DIR" ]]; then
        echo -e "${RED}❌ Cursor rules not found${NC}"
        echo -e "${YELLOW}💡 Run 'cursor-init' first${NC}"
        exit 1
    fi
}

# Pre-commit hook作成
create_pre_commit_hook() {
    cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash

# Cursor Rules Pre-commit Hook
# コミット前にルール確認とタスク更新チェック

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Pre-commit Cursor Rules Check${NC}"
echo "=================================="

# @todo.mdの更新確認
if [[ -f "@todo.md" ]]; then
    if git diff --cached --name-only | grep -q "@todo.md"; then
        echo -e "${GREEN}✅ @todo.md is being updated${NC}"
    else
        echo -e "${YELLOW}⚠️  Consider updating @todo.md with your changes${NC}"
        
        # インタラクティブ確認
        read -p "Continue commit without @todo.md update? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${RED}❌ Commit cancelled${NC}"
            echo -e "${YELLOW}💡 Update @todo.md and try again${NC}"
            exit 1
        fi
    fi
fi

# ルールサマリー表示
if [[ -f ".cursor/rules/globals.mdc" ]]; then
    echo -e "${BLUE}📋 Quick Rules Reminder:${NC}"
    echo "   • タスク分析 → 計画 → 実行 → 品質管理 → 報告"
    echo "   • 重複実装の防止"
    echo "   • 適切なコミットメッセージ形式"
fi

# コミットメッセージ形式の確認
staged_files=$(git diff --cached --name-only)
if [[ -n "$staged_files" ]]; then
    echo -e "${BLUE}📝 Staged files:${NC}"
    echo "$staged_files" | sed 's/^/   • /'
    echo ""
    echo -e "${YELLOW}💡 Remember conventional commit format:${NC}"
    echo "   feat(scope): description"
    echo "   fix(scope): description"
    echo "   docs(scope): description"
fi

echo -e "${GREEN}✅ Pre-commit check completed${NC}"
echo ""
EOF

    chmod +x "$HOOKS_DIR/pre-commit"
    echo -e "${GREEN}✅ Pre-commit hook created${NC}"
}

# Post-commit hook作成
create_post_commit_hook() {
    cat > "$HOOKS_DIR/post-commit" << 'EOF'
#!/bin/bash

# Cursor Rules Post-commit Hook
# コミット後にルールリフレッシュ

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Post-commit Cursor Rules Refresh${NC}"

# ルールファイルのタイムスタンプ更新
if [[ -d ".cursor/rules" ]]; then
    find .cursor/rules -name "*.mdc" -type f -exec touch {} \;
    echo -e "${GREEN}✅ Cursor rules refreshed${NC}"
fi

# タスク管理リマインダー
if [[ -f "@todo.md" ]]; then
    echo -e "${BLUE}📋 Don't forget to update @todo.md if needed${NC}"
fi
EOF

    chmod +x "$HOOKS_DIR/post-commit"
    echo -e "${GREEN}✅ Post-commit hook created${NC}"
}

# Pre-push hook作成
create_pre_push_hook() {
    cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash

# Cursor Rules Pre-push Hook
# プッシュ前の最終確認

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Pre-push Cursor Rules Check${NC}"
echo "================================"

# @todo.mdの状況確認
if [[ -f "@todo.md" ]]; then
    # 進行中タスクの確認
    if grep -q "\[~\]" "@todo.md"; then
        echo -e "${YELLOW}⚠️  You have tasks in progress${NC}"
        echo -e "${BLUE}📋 Current in-progress tasks:${NC}"
        grep -A 5 "\[~\]" "@todo.md" | head -10
        echo ""
    fi
    
    # 緊急タスクの確認
    if grep -q "🔴 緊急" "@todo.md"; then
        urgent_count=$(grep -c "- \[ \]" "@todo.md" | head -1 || echo "0")
        if [[ "$urgent_count" -gt 0 ]]; then
            echo -e "${YELLOW}🔴 You have urgent tasks remaining${NC}"
        fi
    fi
fi

# 品質チェックリマインダー
echo -e "${BLUE}✅ Quality Checklist Reminder:${NC}"
echo "   • Code reviewed"
echo "   • Tests passing"
echo "   • Documentation updated"
echo "   • @todo.md current"

echo -e "${GREEN}✅ Pre-push check completed${NC}"
EOF

    chmod +x "$HOOKS_DIR/pre-push"
    echo -e "${GREEN}✅ Pre-push hook created${NC}"
}

# Prepare-commit-msg hook作成
create_prepare_commit_msg_hook() {
    cat > "$HOOKS_DIR/prepare-commit-msg" << 'EOF'
#!/bin/bash

# Cursor Rules Prepare Commit Message Hook
# コミットメッセージにルール情報を追加

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# コミットメッセージテンプレートの確認・追加
if [[ "$COMMIT_SOURCE" != "merge" && "$COMMIT_SOURCE" != "squash" ]]; then
    # ファイルが空の場合、テンプレートを追加
    if [[ ! -s "$COMMIT_MSG_FILE" ]]; then
        cat >> "$COMMIT_MSG_FILE" << 'TEMPLATE'

# Conventional Commit Format:
# type(scope): description
#
# Types: feat, fix, docs, style, refactor, test, chore
# Example: feat(auth): add user authentication system
#
# Remember to update @todo.md if needed
TEMPLATE
    fi
fi
EOF

    chmod +x "$HOOKS_DIR/prepare-commit-msg"
    echo -e "${GREEN}✅ Prepare-commit-msg hook created${NC}"
}

# フックファイルの統合管理
install_all_hooks() {
    echo -e "${BLUE}🔧 Installing Git hooks for Cursor Rules...${NC}"
    
    # hooksディレクトリ確認
    mkdir -p "$HOOKS_DIR"
    
    # 各フック作成
    create_pre_commit_hook
    create_post_commit_hook
    create_pre_push_hook
    create_prepare_commit_msg_hook
    
    echo ""
    echo -e "${GREEN}✅ All Git hooks installed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Installed hooks:${NC}"
    echo "   • pre-commit: ルール確認 & @todo.md チェック"
    echo "   • post-commit: ルールリフレッシュ"
    echo "   • pre-push: 最終品質チェック"
    echo "   • prepare-commit-msg: コミットメッセージテンプレート"
}

# フックの削除
uninstall_hooks() {
    echo -e "${YELLOW}🗑️  Removing Cursor Rules Git hooks...${NC}"
    
    rm -f "$HOOKS_DIR/pre-commit"
    rm -f "$HOOKS_DIR/post-commit"
    rm -f "$HOOKS_DIR/pre-push"
    rm -f "$HOOKS_DIR/prepare-commit-msg"
    
    echo -e "${GREEN}✅ Git hooks removed${NC}"
}

# フック状況の確認
check_hooks_status() {
    echo -e "${BLUE}📊 Git Hooks Status${NC}"
    echo "==================="
    
    hooks=("pre-commit" "post-commit" "pre-push" "prepare-commit-msg")
    for hook in "${hooks[@]}"; do
        if [[ -f "$HOOKS_DIR/$hook" ]]; then
            echo -e "${GREEN}✅ $hook${NC}"
        else
            echo -e "${RED}❌ $hook${NC}"
        fi
    done
    
    echo ""
}

# メイン実行関数
main() {
    case "${1:-install}" in
        "install")
            check_git_repo
            install_all_hooks
            ;;
        "uninstall")
            check_git_repo
            uninstall_hooks
            ;;
        "status")
            check_git_repo
            check_hooks_status
            ;;
        "help")
            echo "Git Hooks Setup for Cursor Rules"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  install     Install all Git hooks (default)"
            echo "  uninstall   Remove all Git hooks"
            echo "  status      Show hooks installation status"
            echo "  help        Show this help"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@" 