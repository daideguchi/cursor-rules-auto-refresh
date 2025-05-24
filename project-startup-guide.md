# まっさらプロジェクト立ち上げガイド

新規プロジェクトを 0 から始める際の効率的なワークフローです。

## 🎯 パターン 1: ローカル →GitHub（一番スムーズ）

### ステップバイステップ

```bash
# 1. プロジェクト作成 & Cursor rules適用（ワンライナー）
cursor-new my-awesome-project

# 2. プロジェクトディレクトリに移動（自動実行済み）
# cd my-awesome-project

# 3. 基本構成ファイルを追加
echo '{"name": "my-awesome-project", "version": "1.0.0"}' > package.json

# 4. GitHubリポジトリ作成 & プッシュ
gh repo create my-awesome-project --public --push --source=.

# 完了！
```

### 自動で作成されるファイル

```
my-awesome-project/
├── .git/                     # Git初期化済み
├── .gitignore               # 基本的な除外設定
├── README.md                # プロジェクト名入り
├── .cursor/rules/           # 開発ルール一式
│   ├── globals.mdc
│   ├── todo.mdc
│   └── dev-rules/
│       ├── coding-standards.mdc
│       ├── git-workflow.mdc
│       └── testing-guidelines.mdc
└── @todo.md                 # タスク管理ファイル
```

## 🎯 パターン 2: GitHub CLI 統合（GitHub 中心）

```bash
# 1. GitHubリポジトリ作成 & クローン & ルール適用（ワンステップ）
gh cursor-rules create my-awesome-project

# 2. プロジェクト固有の設定
cd my-awesome-project
npm init -y  # または yarn init

# 完了！自動でGitHubにpush済み
```

## 🎯 パターン 3: テンプレートベース

```bash
# 1. 既存テンプレートから作成
gh repo create my-project --template your-org/web-app-template --clone

# 2. Cursor rulesを適用
cd my-project
cursor-init

# 3. 初回コミット
git add .
git commit -m "feat: apply Cursor development rules"
git push
```

## 🎯 パターン 4: 段階的構築

```bash
# 1. 最小構成でスタート
mkdir my-project && cd my-project
git init

# 2. プロジェクトタイプ判定のためのファイル作成
npm init -y  # React/Expressなど選択

# 3. Cursor rules適用（自動判定される）
cursor-init

# 4. GitHub接続
gh repo create --push --source=.
```

## 🤖 プロジェクトタイプ別最適化

### Web Application

```bash
cursor-new my-web-app
cd my-web-app

# React setup
npx create-react-app . --template typescript
# または
npm init vite@latest . -- --template react-ts

# 自動でweb-applicationタイプとして認識される
```

### API Service

```bash
cursor-new my-api
cd my-api

# Express setup
npm init -y
npm install express cors helmet
echo 'console.log("API Server")' > index.js

# 自動でapi-serviceタイプとして認識される
```

### Python Project

```bash
cursor-new my-python-app
cd my-python-app

# Python setup
python -m venv venv
echo "flask" > requirements.txt
echo "print('Hello Python')" > main.py

# 自動でpython-appタイプとして認識される
```

## 📋 実行後の確認チェックリスト

### ✅ 基本チェック

```bash
# ルール適用状況確認
cursor-status

# タスク確認
cat @todo.md

# Git状況確認
git status
gh repo view  # GitHub CLI使用時
```

### ✅ Cursor IDE 設定確認

- Cursor IDE でプロジェクトを開く
- `.cursor/rules/` が認識されているか確認
- `@todo.md` が表示されているか確認

## 🛠️ プロジェクト特化カスタマイズ

### 即座に開発開始するための追加設定

```bash
# ESLint + Prettier (JavaScript/TypeScript)
if [[ -f "package.json" ]]; then
    npm install -D eslint prettier @typescript-eslint/parser
    echo '{"semi": true, "singleQuote": true}' > .prettierrc
fi

# Python用設定
if [[ -f "requirements.txt" ]]; then
    echo "black\nflake8\nmypy" >> requirements.txt
    echo "[tool.black]\nline-length = 88" > pyproject.toml
fi

# Git hooks設定
if [[ -d ".git" ]]; then
    echo "#!/bin/sh\nnpm test" > .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
fi
```

## 💡 プロ・ティップス

### 1. エイリアス設定

```bash
# ~/.bashrc や ~/.zshrc に追加
alias new-web="cursor-new \$1 && cd \$1 && npx create-react-app ."
alias new-api="cursor-new \$1 && cd \$1 && npm init -y && npm install express"
alias new-py="cursor-new \$1 && cd \$1 && python -m venv venv"
```

### 2. プロジェクトテンプレート作成

```bash
# よく使う構成をテンプレート化
mkdir -p ~/.cursor/project-templates/web-app
cd ~/.cursor/project-templates/web-app

# 基本ファイル群を配置
echo "template files..." > ...

# 使用時
cp -r ~/.cursor/project-templates/web-app my-new-project
cd my-new-project
cursor-init
```

### 3. IDE 統合

```bash
# Cursor IDEで直接開く
cursor-new my-project && code my-project
# または
cursor-new my-project && cursor my-project  # Cursor CLI使用時
```

## 🔄 立ち上げ後の標準ワークフロー

### Day 1: プロジェクト基盤

1. `cursor-new project-name` で作成
2. 基本依存関係のインストール
3. 初期コード作成
4. `@todo.md` でタスク管理開始

### Day 2〜: 開発サイクル

1. `@todo.md` でタスク確認
2. コード実装
3. Cursor rules に従った品質チェック
4. Git commit & push
5. `@todo.md` 更新

## 🚨 よくある落とし穴と対策

### 問題 1: プロジェクトタイプ誤認識

```bash
# 対策: 手動でタイプ指定
PROJECT_TYPE=web-application cursor-init
```

### 問題 2: 既存ファイルとの競合

```bash
# 対策: バックアップ確認
ls -la .cursor/rules.backup-*

# 復元が必要な場合
cursor-clean && cursor-init
```

### 問題 3: GitHub 認証エラー

```bash
# 対策: GitHub CLI再認証
gh auth login
```

## 📊 効率性比較

| 方法            | 時間  | 手順数      | 自動化度   |
| --------------- | ----- | ----------- | ---------- |
| **cursor-new**  | 30 秒 | 1 ステップ  | ⭐⭐⭐⭐⭐ |
| 手動作成        | 5 分  | 10+ステップ | ⭐         |
| GitHub template | 2 分  | 3 ステップ  | ⭐⭐⭐     |

結論: `cursor-new project-name` が最も効率的！
