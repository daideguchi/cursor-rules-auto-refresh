#!/bin/bash

# Cursor Rules Auto Refresh System
# 自動でルールを再確認・適用するシステム

set -e

RULES_DIR=".cursor/rules"
REMINDER_FILE=".cursor/.last-reminder"
CURRENT_TIME=$(date +%s)
REMINDER_INTERVAL=3600  # 1時間 (秒)

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ルール存在確認
check_rules_exist() {
    if [[ ! -d "$RULES_DIR" ]]; then
        echo -e "${RED}❌ Cursor rules not found${NC}"
        echo -e "${YELLOW}💡 Run 'cursor-init' to install rules${NC}"
        return 1
    fi
    return 0
}

# ルールサマリー表示
show_rules_summary() {
    echo -e "${BLUE}📋 Current Cursor Rules Summary${NC}"
    echo "=================================="
    
    if [[ -f "$RULES_DIR/globals.mdc" ]]; then
        echo -e "${GREEN}✅ Global Development Process${NC}"
    fi
    
    if [[ -f "$RULES_DIR/todo.mdc" ]]; then
        echo -e "${GREEN}✅ Task Management Guidelines${NC}"
    fi
    
    if [[ -d "$RULES_DIR/dev-rules" ]]; then
        echo -e "${GREEN}✅ Development Rules:${NC}"
        find "$RULES_DIR/dev-rules" -name "*.mdc" -type f | while read -r file; do
            rule_name=$(basename "$file" .mdc)
            echo -e "   • $rule_name"
        done
    fi
    
    if [[ -f "$RULES_DIR/uiux.mdc" ]]; then
        echo -e "${GREEN}✅ UI/UX Guidelines${NC}"
    fi
    
    echo ""
}

# 重要ルールのハイライト表示
show_key_reminders() {
    echo -e "${YELLOW}🎯 Key Reminders${NC}"
    echo "=================="
    
    # globals.mdcから重要ポイントを抽出
    if [[ -f "$RULES_DIR/globals.mdc" ]]; then
        echo -e "${BLUE}📝 Development Process:${NC}"
        echo "   1. タスク分析 → 計画 → 実行 → 品質管理 → 報告"
        echo "   2. 重複実装の防止を常に意識"
        echo "   3. 不明点は事前確認、重要判断は承認取得"
    fi
    
    # todo管理の確認
    if [[ -f "@todo.md" ]]; then
        echo -e "${BLUE}📋 Task Management:${NC}"
        echo "   • @todo.md を随時更新"
        echo "   • 機能実装後は必ずタスク状況を更新"
    fi
    
    # 開発ルールのチェック
    if [[ -f "$RULES_DIR/dev-rules/coding-standards.mdc" ]]; then
        echo -e "${BLUE}💻 Coding Standards:${NC}"
        echo "   • 型安全性の確保"
        echo "   • 適切なエラーハンドリング"
        echo "   • テストカバレッジ80%以上"
    fi
    
    echo ""
}

# Git状況と連携したアドバイス
show_git_advice() {
    if [[ -d ".git" ]]; then
        echo -e "${YELLOW}🔄 Git Workflow Reminders${NC}"
        echo "=========================="
        
        # 未コミットファイルの確認
        if git diff --quiet && git diff --staged --quiet; then
            echo -e "${GREEN}✅ Working directory clean${NC}"
        else
            echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
            echo "   Remember: Clear commit messages following conventional format"
            echo "   Example: feat(auth): add user authentication system"
        fi
        
        # ブランチ確認
        current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        echo -e "${BLUE}📍 Current branch: $current_branch${NC}"
        
        if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
            echo -e "${YELLOW}⚠️  Working on main branch${NC}"
            echo "   Consider creating a feature branch for new work"
        fi
        
        echo ""
    fi
}

# Cursor IDE設定のチェック
check_cursor_integration() {
    echo -e "${YELLOW}🖥️  Cursor IDE Integration${NC}"
    echo "==========================="
    
    # .cursor/settings.json の確認・作成
    if [[ ! -f ".cursor/settings.json" ]]; then
        echo -e "${YELLOW}📝 Creating Cursor IDE settings...${NC}"
        cat > .cursor/settings.json << 'EOF'
{
  "cursor.rules.autoRefresh": true,
  "cursor.rules.showReminders": true,
  "cursor.rules.reminderInterval": 3600,
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/.git/**": true,
    "**/dist/**": true
  },
  "cursor.rules.files": [
    ".cursor/rules/globals.mdc",
    ".cursor/rules/todo.mdc",
    ".cursor/rules/dev-rules/*.mdc",
    "@todo.md"
  ]
}
EOF
        echo -e "${GREEN}✅ Cursor settings created${NC}"
    else
        echo -e "${GREEN}✅ Cursor settings exist${NC}"
    fi
    
    echo ""
}

# リマインダータイミングの確認
should_show_reminder() {
    if [[ ! -f "$REMINDER_FILE" ]]; then
        return 0  # 初回は表示
    fi
    
    last_reminder=$(cat "$REMINDER_FILE" 2>/dev/null || echo "0")
    time_diff=$((CURRENT_TIME - last_reminder))
    
    if [[ $time_diff -gt $REMINDER_INTERVAL ]]; then
        return 0  # 間隔経過で表示
    fi
    
    return 1  # まだ表示しない
}

# リマインダー時刻の更新
update_reminder_time() {
    mkdir -p "$(dirname "$REMINDER_FILE")"
    echo "$CURRENT_TIME" > "$REMINDER_FILE"
}

# ルールファイルの自動リロード
auto_reload_rules() {
    echo -e "${BLUE}🔄 Auto-reloading Cursor rules...${NC}"
    
    # ファイル変更監視用のマーカーファイル作成
    touch .cursor/.rules-refreshed
    
    # Cursor IDEにファイル変更を通知（ファイルタイムスタンプ更新）
    find "$RULES_DIR" -name "*.mdc" -type f -exec touch {} \;
    
    echo -e "${GREEN}✅ Rules refreshed for Cursor IDE${NC}"
}

# メイン実行関数
main() {
    case "${1:-auto}" in
        "auto")
            if check_rules_exist; then
                if should_show_reminder; then
                    clear
                    echo -e "${GREEN}🎯 Cursor Rules Auto-Refresh${NC}"
                    echo "=============================="
                    echo ""
                    
                    show_rules_summary
                    show_key_reminders
                    show_git_advice
                    check_cursor_integration
                    auto_reload_rules
                    
                    update_reminder_time
                    
                    echo -e "${YELLOW}💡 This reminder shows every hour during active development${NC}"
                    echo -e "${YELLOW}   To disable: rm .cursor/.last-reminder${NC}"
                    echo ""
                fi
            fi
            ;;
        "force")
            if check_rules_exist; then
                show_rules_summary
                show_key_reminders
                show_git_advice
                auto_reload_rules
                update_reminder_time
            fi
            ;;
        "summary")
            if check_rules_exist; then
                show_rules_summary
            fi
            ;;
        "reload")
            if check_rules_exist; then
                auto_reload_rules
            fi
            ;;
        "help")
            echo "Cursor Rules Auto-Refresh System"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  auto      Auto-refresh with timing check (default)"
            echo "  force     Force show reminders and reload"
            echo "  summary   Show rules summary only"
            echo "  reload    Reload rules for Cursor IDE"
            echo "  help      Show this help"
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