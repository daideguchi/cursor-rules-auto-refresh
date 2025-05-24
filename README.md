# Cursor Rules - Git Repository

標準化された開発ルールを Git リポジトリで管理し、ワンライナーで任意のプロジェクトに適用できるソリューションです。

## 🚀 ワンライナーでルール適用

### 新規プロジェクトへの適用

```bash
curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash
```

### 既存プロジェクトの更新

```bash
curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/update.sh | bash
```

## 🛠️ セットアップ方法

### 1. シェル関数の追加（推奨）

`~/.bashrc` または `~/.zshrc` に以下を追加：

```bash
# Cursor Rules Quick Commands
source <(curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/shell-functions.sh)
```

これにより以下のコマンドが使用可能になります：

```bash
cursor-init              # 現在のディレクトリにルール適用
cursor-new my-project    # 新規プロジェクト作成+ルール適用
cursor-clone <repo-url>  # リポジトリクローン+ルール適用
cursor-update            # ルール更新
cursor-status            # ルール状況確認
cursor-clean             # ルール削除
cursor-help              # ヘルプ表示
```

### 2. GitHub CLI 拡張（オプション）

GitHub CLI ユーザーの場合：

```bash
# 拡張インストール
gh extension install your-org/gh-cursor-rules

# または直接実行
gh cursor-rules init
gh cursor-rules create my-awesome-project
```

## 📁 自動的に作成されるファイル

### ディレクトリ構造

```
project/
├── .cursor/
│   └── rules/
│       ├── globals.mdc           # コア開発プロセス
│       ├── todo.mdc             # タスク管理ルール
│       ├── uiux.mdc             # UI/UXガイドライン（該当時）
│       └── dev-rules/
│           ├── coding-standards.mdc
│           ├── git-workflow.mdc
│           └── testing-guidelines.mdc
└── @todo.md                     # プロジェクト専用タスク管理
```

## 🤖 自動判定機能

スクリプトは以下のファイルを検出してプロジェクトタイプを自動判定：

| ファイル                             | 判定されるタイプ | 適用されるルール  |
| ------------------------------------ | ---------------- | ----------------- |
| `package.json` (React/Vue/Angular)   | web-application  | 全ルール + UI/UX  |
| `package.json` (Express/Fastify)     | api-service      | コア + 開発ルール |
| `requirements.txt`, `pyproject.toml` | python-app       | コア + 開発ルール |
| `go.mod`                             | go-service       | コア + 開発ルール |
| `Cargo.toml`                         | rust-app         | コア + 開発ルール |
| その他                               | general          | 全ルール          |

## 🔄 更新戦略

### 自動バックアップ

- 更新時に自動的に `.cursor/rules.backup-YYYYMMDD-HHMMSS` にバックアップ作成
- 問題が発生した場合は簡単にロールバック可能

### 選択的更新

```bash
# インタラクティブな更新選択
curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/update.sh | bash

# 1) 全ルール更新（カスタマイズを上書き）
# 2) コアルールのみ更新（dev-rulesのカスタマイズを保持）
# 3) 更新キャンセル
```

## 💡 実用例

### 新しい Web アプリプロジェクト

```bash
mkdir my-web-app
cd my-web-app
npm init -y
npm install react react-dom
cursor-init  # または curl版
```

### 既存リポジトリのフォーク＋ルール適用

```bash
cursor-clone https://github.com/awesome/project.git my-fork
```

### GitHub CLI でリポジトリ作成＋ルール適用

```bash
gh cursor-rules create my-new-service api-service
```

## 🏢 組織でのカスタマイズ

### 1. フォークして組織用にカスタマイズ

```bash
# 1. このリポジトリをフォーク
gh repo fork your-org/cursor-rules --clone

# 2. ルールをカスタマイズ
cd cursor-rules
# templates/ 内のファイルを編集

# 3. 組織のリポジトリにプッシュ
git add .
git commit -m "feat: customize rules for our organization"
git push origin main
```

### 2. プライベートリポジトリでの使用

```bash
# プライベートリポジトリの場合
curl -H "Authorization: token $GITHUB_TOKEN" \
     -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash
```

### 3. 社内サーバーでの運用

```bash
# 社内サーバーでホスト
curl -fsSL https://git.company.com/dev-tools/cursor-rules/raw/main/install.sh | bash
```

## 🔧 高度な使用方法

### プロジェクトタイプの強制指定

```bash
# 環境変数でプロジェクトタイプを指定
PROJECT_TYPE=web-application curl -fsSL .../install.sh | bash
```

### 特定ルールのみ適用

```bash
# カスタムインストールスクリプト
RULES="coding-standards,git-workflow" curl -fsSL .../install.sh | bash
```

### CI/CD での自動適用

```yaml
# .github/workflows/setup.yml
name: Apply Cursor Rules
on:
  workflow_dispatch:

jobs:
  apply-rules:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Apply Cursor Rules
        run: |
          curl -fsSL https://raw.githubusercontent.com/your-org/cursor-rules/main/install.sh | bash
          git add .cursor @todo.md .gitignore
          git commit -m "feat: apply Cursor development rules" || exit 0
          git push
```

## 🆚 他のアプローチとの比較

| アプローチ      | 設定の簡単さ | 更新の容易さ | 依存関係 | 推奨用途             |
| --------------- | ------------ | ------------ | -------- | -------------------- |
| **Git + curl**  | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐     | なし     | 個人・小規模チーム   |
| npm package     | ⭐⭐⭐       | ⭐⭐⭐⭐⭐   | Node.js  | 中規模チーム         |
| GitHub Template | ⭐⭐⭐⭐     | ⭐⭐         | GitHub   | 新規プロジェクト中心 |
| Git Submodule   | ⭐⭐         | ⭐⭐         | Git      | 高度なバージョン管理 |

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 新しいブランチ作成: `git checkout -b feature/improvement`
3. ルールやスクリプトを改善
4. コミット: `git commit -m "feat: improve XYZ"`
5. プッシュ: `git push origin feature/improvement`
6. Pull Request 作成

## 📄 ライセンス

MIT License - プロジェクトで自由に使用・改変可能
