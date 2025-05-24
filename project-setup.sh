#!/bin/bash

# Cursor Rules Project Setup Script
# 新規プロジェクトを完全自動化でセットアップ

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 設定
CURSOR_RULES_REPO="https://raw.githubusercontent.com/daideguchi/cursor-rules-auto-refresh/main"

# プロジェクトタイプ定義
declare -A PROJECT_TYPES=(
    ["react"]="React Web Application"
    ["vue"]="Vue.js Web Application"
    ["angular"]="Angular Web Application"
    ["next"]="Next.js Web Application"
    ["node-api"]="Node.js API Service"
    ["express"]="Express.js API Service"
    ["python-web"]="Python Web Application (FastAPI/Django)"
    ["python-api"]="Python API Service"
    ["go-api"]="Go API Service"
    ["rust-api"]="Rust API Service"
    ["mobile-rn"]="React Native Mobile App"
    ["mobile-flutter"]="Flutter Mobile App"
    ["desktop"]="Desktop Application (Electron/Tauri)"
    ["library"]="Library/Package"
    ["fullstack"]="Full-stack Application"
    ["general"]="General Project"
)

# ヘルプ表示
show_help() {
    echo -e "${BLUE}🚀 Cursor Rules Project Setup${NC}"
    echo ""
    echo "Usage: $0 <project-name> [project-type]"
    echo ""
    echo -e "${YELLOW}Available project types:${NC}"
    for key in "${!PROJECT_TYPES[@]}"; do
        echo "  $key - ${PROJECT_TYPES[$key]}"
    done
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 my-awesome-app react"
    echo "  $0 my-api node-api"
    echo "  $0 my-project  # Interactive mode"
    echo ""
    echo -e "${YELLOW}What this script does:${NC}"
    echo "  ✅ Create project directory"
    echo "  ✅ Initialize Git repository"
    echo "  ✅ Apply Cursor Rules with auto-refresh"
    echo "  ✅ Create project-specific files"
    echo "  ✅ Set up development environment"
    echo "  ✅ Enable Git hooks"
    echo "  ✅ Create initial commit"
    echo "  ✅ Initialize development session"
}

# プロジェクトタイプ選択（インタラクティブ）
select_project_type() {
    echo -e "${YELLOW}📋 Select Project Type:${NC}"
    echo ""
    
    local types=($(printf '%s\n' "${!PROJECT_TYPES[@]}" | sort))
    local i=1
    
    for type in "${types[@]}"; do
        echo -e "  ${BLUE}$i)${NC} $type - ${PROJECT_TYPES[$type]}"
        ((i++))
    done
    
    echo ""
    read -p "Enter number (1-${#types[@]}): " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#types[@]}" ]; then
        echo "${types[$((selection-1))]}"
    else
        echo "general"
    fi
}

# React プロジェクト作成
create_react_project() {
    local project_name="$1"
    echo -e "${BLUE}⚛️  Creating React project...${NC}"
    
    npx create-react-app "$project_name" --template typescript --yes
    cd "$project_name"
    
    # 追加パッケージ
    npm install --save-dev eslint-config-prettier prettier
    
    # .prettierrc作成
    cat > .prettierrc << 'EOF'
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
EOF
    
    # ESLint設定更新
    cat > .eslintrc.json << 'EOF'
{
  "extends": [
    "react-app",
    "react-app/jest",
    "prettier"
  ],
  "rules": {
    "no-console": "warn",
    "prefer-const": "error"
  }
}
EOF
}

# Vue プロジェクト作成
create_vue_project() {
    local project_name="$1"
    echo -e "${BLUE}🍃 Creating Vue.js project...${NC}"
    
    npm create vue@latest "$project_name" -- --typescript --eslint --prettier --yes
    cd "$project_name"
    npm install
}

# Next.js プロジェクト作成
create_next_project() {
    local project_name="$1"
    echo -e "${BLUE}▲ Creating Next.js project...${NC}"
    
    npx create-next-app@latest "$project_name" --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --yes
    cd "$project_name"
}

# Node.js API プロジェクト作成
create_node_api_project() {
    local project_name="$1"
    echo -e "${BLUE}🟢 Creating Node.js API project...${NC}"
    
    mkdir "$project_name" && cd "$project_name"
    
    # package.json作成
    cat > package.json << EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOF
    
    # 依存関係インストール
    npm install express cors helmet dotenv
    npm install --save-dev nodemon jest supertest eslint prettier
    
    # ディレクトリ構造作成
    mkdir -p src/{routes,middleware,models,controllers}
    
    # 基本ファイル作成
    cat > src/index.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'API is running!' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF
    
    cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
EOF
}

# Python Web プロジェクト作成
create_python_web_project() {
    local project_name="$1"
    echo -e "${BLUE}🐍 Creating Python web project...${NC}"
    
    mkdir "$project_name" && cd "$project_name"
    
    # 仮想環境作成
    python3 -m venv venv
    source venv/bin/activate || . venv/Scripts/activate  # Windows対応
    
    # requirements.txt作成
    cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.5.0
python-dotenv==1.0.0
pytest==7.4.3
black==23.11.0
flake8==6.1.0
EOF
    
    pip install -r requirements.txt
    
    # ディレクトリ構造作成
    mkdir -p app/{api,core,models,schemas}
    
    # 基本ファイル作成
    cat > app/main.py << 'EOF'
from fastapi import FastAPI
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="API", version="1.0.0")

@app.get("/")
async def root():
    return {"message": "Hello World"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
    
    cat > .env << 'EOF'
DEBUG=True
DATABASE_URL=sqlite:///./app.db
EOF
    
    # Python設定ファイル
    cat > pyproject.toml << 'EOF'
[tool.black]
line-length = 88
target-version = ['py39']

[tool.pytest.ini_options]
testpaths = ["tests"]
EOF
}

# Go API プロジェクト作成
create_go_api_project() {
    local project_name="$1"
    echo -e "${BLUE}🐹 Creating Go API project...${NC}"
    
    mkdir "$project_name" && cd "$project_name"
    
    # Go mod初期化
    go mod init "$project_name"
    
    # 依存関係追加
    go get github.com/gin-gonic/gin
    go get github.com/joho/godotenv
    
    # ディレクトリ構造作成
    mkdir -p {cmd,internal/{handlers,models,services},pkg}
    
    # 基本ファイル作成
    cat > main.go << 'EOF'
package main

import (
    "log"
    "os"

    "github.com/gin-gonic/gin"
    "github.com/joho/godotenv"
)

func main() {
    // Load .env file
    if err := godotenv.Load(); err != nil {
        log.Println("No .env file found")
    }

    r := gin.Default()
    
    r.GET("/", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "message": "Hello World",
        })
    })

    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    r.Run(":" + port)
}
EOF
    
    cat > .env << 'EOF'
PORT=8080
GIN_MODE=debug
EOF
}

# 一般プロジェクト作成
create_general_project() {
    local project_name="$1"
    echo -e "${BLUE}📁 Creating general project...${NC}"
    
    mkdir "$project_name" && cd "$project_name"
    
    # 基本ファイル作成
    echo "# $project_name" > README.md
    
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
venv/
env/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build
dist/
build/
*.tsbuildinfo

# Cache
.cache/
.parcel-cache/
EOF
}

# Cursor Rules 適用
apply_cursor_rules() {
    echo -e "${PURPLE}🎯 Applying Cursor Rules...${NC}"
    
    # Cursor Rules インストール
    curl -fsSL "$CURSOR_RULES_REPO/install.sh" | bash
    
    # 自動リフレッシュ有効化
    if command -v cursor-auto >/dev/null 2>&1; then
        cursor-auto on
    else
        # シェル関数読み込み
        curl -fsSL "$CURSOR_RULES_REPO/shell-functions.sh" >> ~/.bashrc
        source ~/.bashrc 2>/dev/null || true
        cursor-auto on 2>/dev/null || true
    fi
}

# 初回コミット作成
create_initial_commit() {
    echo -e "${GREEN}📝 Creating initial commit...${NC}"
    
    git add .
    git commit -m "feat: initial project setup with Cursor Rules

- Set up project structure
- Apply Cursor development rules
- Configure auto-refresh system
- Add basic development files"
}

# 開発セッション初期化
initialize_dev_session() {
    echo -e "${GREEN}🚀 Initializing development session...${NC}"
    
    # シェル関数が利用可能か確認
    if command -v cursor-start >/dev/null 2>&1; then
        cursor-start
    else
        echo -e "${YELLOW}💡 Run 'cursor-start' after sourcing shell functions${NC}"
    fi
}

# メイン実行関数
main() {
    local project_name="$1"
    local project_type="$2"
    
    # 引数チェック
    if [[ -z "$project_name" ]]; then
        show_help
        exit 1
    fi
    
    # プロジェクトタイプ決定
    if [[ -z "$project_type" ]]; then
        project_type=$(select_project_type)
    fi
    
    # プロジェクトタイプ検証
    if [[ ! "${PROJECT_TYPES[$project_type]}" ]]; then
        echo -e "${RED}❌ Invalid project type: $project_type${NC}"
        echo -e "${YELLOW}💡 Run '$0 --help' to see available types${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Setting up new project: ${YELLOW}$project_name${NC}"
    echo -e "${BLUE}📋 Project type: ${YELLOW}${PROJECT_TYPES[$project_type]}${NC}"
    echo ""
    
    # プロジェクト既存チェック
    if [[ -d "$project_name" ]]; then
        echo -e "${RED}❌ Directory '$project_name' already exists${NC}"
        exit 1
    fi
    
    # プロジェクト作成
    case "$project_type" in
        "react") create_react_project "$project_name" ;;
        "vue") create_vue_project "$project_name" ;;
        "next") create_next_project "$project_name" ;;
        "node-api"|"express") create_node_api_project "$project_name" ;;
        "python-web"|"python-api") create_python_web_project "$project_name" ;;
        "go-api") create_go_api_project "$project_name" ;;
        *) create_general_project "$project_name" ;;
    esac
    
    # Git初期化（create-*で既に初期化されている場合をスキップ）
    if [[ ! -d ".git" ]]; then
        echo -e "${BLUE}📋 Initializing Git repository...${NC}"
        git init
    fi
    
    # Cursor Rules適用
    apply_cursor_rules
    
    # 初回コミット
    create_initial_commit
    
    # 完了メッセージ
    echo ""
    echo -e "${GREEN}✅ Project setup completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📁 Project location: $(pwd)${NC}"
    echo -e "${YELLOW}🎯 Project type: ${PROJECT_TYPES[$project_type]}${NC}"
    echo ""
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo "  1. cd $project_name"
    echo "  2. cursor-start    # Initialize development session"
    echo "  3. cursor-remind   # Review development rules"
    echo ""
    echo -e "${BLUE}💡 Available commands:${NC}"
    echo "  cursor-auto status   # Check auto-refresh status"
    echo "  cursor-remind        # Quick rules reminder"
    echo "  cursor-start         # Start development session"
    echo ""
    
    # 開発セッション初期化
    initialize_dev_session
}

# ヘルプオプション
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# スクリプト実行
main "$@" 