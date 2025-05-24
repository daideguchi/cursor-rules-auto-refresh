# Cursor Rules Shell Functions
# Add these functions to your ~/.bashrc or ~/.zshrc

# 自動ルールリフレッシュの有効化/無効化
cursor-auto() {
    case "${1:-status}" in
        "on"|"enable")
            # 自動リフレッシュを有効化
            if [[ -f ".cursor/rules/auto-rules-refresh.sh" ]]; then
                # crontabに登録（15分ごと）
                (crontab -l 2>/dev/null | grep -v "auto-rules-refresh"; echo "*/15 * * * * cd $(pwd) && bash .cursor/rules/auto-rules-refresh.sh auto") | crontab -
                echo "✅ Auto-refresh enabled (every 15 minutes)"
            else
                echo "❌ Auto-refresh script not found. Run 'cursor-init' first."
            fi
            ;;
        "off"|"disable")
            # 自動リフレッシュを無効化
            crontab -l 2>/dev/null | grep -v "auto-rules-refresh" | crontab -
            echo "✅ Auto-refresh disabled"
            ;;
        "status")
            # 現在の状態確認
            if crontab -l 2>/dev/null | grep -q "auto-rules-refresh"; then
                echo "🟢 Auto-refresh: ENABLED"
            else
                echo "🔴 Auto-refresh: DISABLED"
            fi
            ;;
        "force")
            # 強制実行
            if [[ -f ".cursor/rules/auto-rules-refresh.sh" ]]; then
                bash .cursor/rules/auto-rules-refresh.sh force
            else
                echo "❌ Auto-refresh script not found"
            fi
            ;;
        *)
            echo "Usage: cursor-auto [on|off|status|force]"
            echo "  on      Enable auto-refresh (every 15 minutes)"
            echo "  off     Disable auto-refresh"
            echo "  status  Show current status"
            echo "  force   Force refresh now"
            ;;
    esac
}

# ルール忘れ防止のクイックリマインダー
cursor-remind() {
    local reminder_type="${1:-quick}"
    
    case "$reminder_type" in
        "quick"|"q")
            echo "🎯 Quick Rules Reminder:"
            echo "   1. タスク分析 → 計画 → 実行 → 品質管理 → 報告"
            echo "   2. 重複実装の防止"
            echo "   3. @todo.md の随時更新"
            echo "   4. 適切なコミットメッセージ"
            ;;
        "full"|"f")
            if [[ -f ".cursor/rules/auto-rules-refresh.sh" ]]; then
                bash .cursor/rules/auto-rules-refresh.sh summary
            else
                echo "❌ Rules not found. Run 'cursor-init' first."
            fi
            ;;
        "todo"|"t")
            if [[ -f "@todo.md" ]]; then
                echo "📋 Current @todo.md status:"
                grep -E "^###|^- \[" "@todo.md" | head -20
            else
                echo "❌ @todo.md not found"
            fi
            ;;
        *)
            echo "Usage: cursor-remind [quick|full|todo]"
            echo "  quick   Show quick reminder (default)"
            echo "  full    Show full rules summary"
            echo "  todo    Show @todo.md status"
            ;;
    esac
}

# 開発セッション開始時の自動チェック
cursor-start() {
    echo "🚀 Starting development session..."
    
    # ルール確認
    if [[ -f ".cursor/rules/auto-rules-refresh.sh" ]]; then
        bash .cursor/rules/auto-rules-refresh.sh force
    fi
    
    # Git hooks確認
    if [[ -f ".cursor/rules/git-hooks-setup.sh" ]]; then
        bash .cursor/rules/git-hooks-setup.sh status
    fi
    
    # @todo.md確認
    if [[ -f "@todo.md" ]]; then
        echo "📋 Today's tasks:"
        grep -A 10 "🔴 緊急\|🟡 重要" "@todo.md" | head -20
    fi
    
    echo "✅ Development session initialized!"
}

# Quick install Cursor rules in current directory
cursor-init() {
    echo "🚀 Initializing Cursor rules..."
    curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash
}

# Update existing Cursor rules
cursor-update() {
    echo "🔄 Updating Cursor rules..."
    curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/update.sh | bash
}

# Create new project with Cursor rules
cursor-new() {
    local project_name="$1"
    if [[ -z "$project_name" ]]; then
        echo "Usage: cursor-new <project-name>"
        return 1
    fi
    
    echo "📁 Creating new project: $project_name"
    mkdir -p "$project_name"
    cd "$project_name"
    
    # Initialize git
    git init
    
    # Create basic files
    echo "# $project_name" > README.md
    echo "node_modules/" > .gitignore
    echo ".env" >> .gitignore
    
    # Apply Cursor rules
    cursor-init
    
    echo "✅ Project '$project_name' created with Cursor rules!"
}

# Clone repository and apply Cursor rules
cursor-clone() {
    local repo_url="$1"
    local project_name="$2"
    
    if [[ -z "$repo_url" ]]; then
        echo "Usage: cursor-clone <repo-url> [project-name]"
        return 1
    fi
    
    if [[ -z "$project_name" ]]; then
        project_name=$(basename "$repo_url" .git)
    fi
    
    echo "📥 Cloning repository..."
    git clone "$repo_url" "$project_name"
    cd "$project_name"
    
    echo "🚀 Applying Cursor rules..."
    cursor-init
    
    echo "✅ Repository cloned and rules applied!"
}

# Check if Cursor rules are installed
cursor-status() {
    if [[ -d ".cursor/rules" ]]; then
        echo "✅ Cursor rules are installed"
        echo "📁 Rules directory: .cursor/rules"
        echo "📋 Installed rules:"
        find .cursor/rules -name "*.mdc" -type f | sed 's|.cursor/rules/||' | sort
        
        if [[ -f "@todo.md" ]]; then
            echo "📝 Task management file: @todo.md"
        fi
    else
        echo "❌ Cursor rules not found"
        echo "💡 Run 'cursor-init' to install"
    fi
}

# Remove Cursor rules
cursor-clean() {
    if [[ -d ".cursor/rules" ]]; then
        read -p "❓ Remove Cursor rules? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf .cursor/rules
            rm -f @todo.md
            echo "🗑️  Cursor rules removed"
        else
            echo "❌ Cancelled"
        fi
    else
        echo "❌ No Cursor rules found"
    fi
}

# Show available commands
cursor-help() {
    echo "🎯 Cursor Rules Commands:"
    echo ""
    echo "=== Core Commands ==="
    echo "  cursor-init      Initialize Cursor rules in current directory"
    echo "  cursor-update    Update existing Cursor rules"
    echo "  cursor-new       Create new project with Cursor rules"
    echo "  cursor-clone     Clone repo and apply Cursor rules"
    echo "  cursor-status    Check Cursor rules installation status"
    echo "  cursor-clean     Remove Cursor rules from current directory"
    echo ""
    echo "=== Auto-Refresh Commands ==="
    echo "  cursor-auto      Manage auto-refresh (on/off/status/force)"
    echo "  cursor-remind    Quick rules reminder (quick/full/todo)"
    echo "  cursor-start     Initialize development session"
    echo "  cursor-help      Show this help message"
    echo ""
    echo "💡 Examples:"
    echo "  cursor-new my-awesome-project    # Create project with rules"
    echo "  cursor-clone https://github.com/user/repo.git"
    echo "  cursor-init                      # Add rules to existing project"
    echo "  cursor-auto on                   # Enable auto-refresh"
    echo "  cursor-remind                    # Quick rules reminder"
    echo "  cursor-start                     # Start development session"
} 