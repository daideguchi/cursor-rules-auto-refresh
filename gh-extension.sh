#!/bin/bash

# GitHub CLI Extension for Cursor Rules
# Usage: gh cursor-rules [command]

case "$1" in
    "init"|"")
        echo "🚀 GitHub CLI + Cursor Rules Integration"
        echo "📥 Installing Cursor rules from GitHub..."
        curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash
        ;;
        
    "create")
        project_name="$2"
        template="$3"
        
        if [[ -z "$project_name" ]]; then
            echo "Usage: gh cursor-rules create <project-name> [template]"
            exit 1
        fi
        
        if [[ -n "$template" ]]; then
            echo "📁 Creating project from template: $template"
            gh repo create "$project_name" --template "$template" --clone
        else
            echo "📁 Creating new project: $project_name"
            gh repo create "$project_name" --private --clone
        fi
        
        cd "$project_name"
        
        # Initialize basic structure
        if [[ ! -f "README.md" ]]; then
            echo "# $project_name" > README.md
        fi
        
        if [[ ! -f ".gitignore" ]]; then
            cat > .gitignore << 'EOF'
node_modules/
.env
.DS_Store
*.log
EOF
        fi
        
        # Apply Cursor rules
        echo "🚀 Applying Cursor rules..."
        curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash
        
        # Initial commit
        git add .
        git commit -m "feat: initial project setup with Cursor rules"
        git push origin main
        
        echo "✅ Project '$project_name' created with Cursor rules!"
        ;;
        
    "fork")
        repo_url="$2"
        if [[ -z "$repo_url" ]]; then
            echo "Usage: gh cursor-rules fork <repo-url>"
            exit 1
        fi
        
        echo "🍴 Forking repository..."
        gh repo fork "$repo_url" --clone
        
        repo_name=$(basename "$repo_url" .git)
        cd "$repo_name"
        
        echo "🚀 Applying Cursor rules..."
        curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash
        
        # Commit rules
        git add .cursor @todo.md .gitignore 2>/dev/null || true
        git commit -m "feat: add Cursor development rules" 2>/dev/null || true
        
        echo "✅ Repository forked and rules applied!"
        ;;
        
    "template")
        echo "🎯 Available project templates with Cursor rules:"
        echo ""
        echo "  web-app       React/Vue/Angular web application"
        echo "  api-service   Express/FastAPI backend service"
        echo "  library       Reusable library/package"
        echo "  fullstack     Full-stack application"
        echo "  mobile        React Native/Flutter mobile app"
        echo ""
        echo "💡 Usage:"
        echo "  gh cursor-rules create my-project web-app"
        ;;
        
    "update")
        echo "🔄 Updating Cursor rules..."
        curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/update.sh | bash
        ;;
        
    "status")
        if [[ -d ".cursor/rules" ]]; then
            echo "✅ Cursor rules are installed"
            echo "📊 Repository status:"
            
            if command -v gh >/dev/null 2>&1; then
                repo_info=$(gh repo view --json name,owner,visibility 2>/dev/null)
                if [[ $? -eq 0 ]]; then
                    echo "  Repository: $(echo "$repo_info" | jq -r '.owner.login + "/" + .name')"
                    echo "  Visibility: $(echo "$repo_info" | jq -r '.visibility')"
                fi
            fi
            
            echo "📋 Installed rules:"
            find .cursor/rules -name "*.mdc" -type f | sed 's|.cursor/rules/||' | sort
        else
            echo "❌ Cursor rules not found"
            echo "💡 Run 'gh cursor-rules init' to install"
        fi
        ;;
        
    "help"|"-h"|"--help")
        echo "🎯 GitHub CLI Cursor Rules Extension"
        echo ""
        echo "Commands:"
        echo "  init              Install Cursor rules in current repository"
        echo "  create <name>     Create new repository with Cursor rules"
        echo "  fork <repo>       Fork repository and apply Cursor rules"
        echo "  template          Show available project templates"
        echo "  update            Update existing Cursor rules"
        echo "  status            Show rules and repository status"
        echo "  help              Show this help message"
        echo ""
        echo "💡 Examples:"
        echo "  gh cursor-rules init"
        echo "  gh cursor-rules create my-awesome-app web-app"
        echo "  gh cursor-rules fork octocat/Hello-World"
        ;;
        
    *)
        echo "❌ Unknown command: $1"
        echo "💡 Run 'gh cursor-rules help' for available commands"
        exit 1
        ;;
esac 