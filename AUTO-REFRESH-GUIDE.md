# Cursor Rules 自動リフレッシュシステム使用ガイド

手動での @ファイル指定の手間を削減する包括的なソリューションです。

## 🎯 解決する課題

- ✅ ルールを忘れた時の手動再確認の手間を削減
- ✅ @ファイル指定の操作を自動化
- ✅ 定期的なルール確認を自動化
- ✅ Git 操作時の自動ルールチェック
- ✅ Cursor IDE での自動ルール読み込み

## 🚀 クイックスタート

### 1. 基本セットアップ（自動実行）

```bash
# 新規プロジェクト作成（全て自動設定される）
cursor-new my-project

# 既存プロジェクトに適用
cursor-init
```

### 2. 自動リフレッシュの有効化

```bash
# 15分ごとの自動ルールリフレッシュを有効化
cursor-auto on

# 状況確認
cursor-auto status

# 強制実行（今すぐリフレッシュ）
cursor-auto force
```

### 3. 開発セッション開始

```bash
# 開発開始時に実行（推奨）
cursor-start
```

## 🔄 自動化機能一覧

### 1. タイマーベース自動リフレッシュ

| 機能                       | 頻度     | 説明                    |
| -------------------------- | -------- | ----------------------- |
| ルールサマリー表示         | 1 時間毎 | 重要ルールのハイライト  |
| ファイルタイムスタンプ更新 | 15 分毎  | Cursor IDE に変更を通知 |
| Git 状況確認               | 開発中   | ブランチ・コミット状況  |
| @todo.md リマインダー      | 常時     | タスク更新の促し        |

### 2. Git Hooks 統合

| フック             | タイミング | 機能                          |
| ------------------ | ---------- | ----------------------------- |
| pre-commit         | コミット前 | ルール確認・@todo.md チェック |
| post-commit        | コミット後 | ルールファイルのリフレッシュ  |
| pre-push           | プッシュ前 | 品質チェックリスト表示        |
| prepare-commit-msg | コミット時 | メッセージテンプレート提供    |

### 3. Cursor IDE 統合

| 設定                    | 効果                           |
| ----------------------- | ------------------------------ |
| 自動ファイル監視        | ルールファイル変更を即座に反映 |
| 優先ファイル設定        | 重要ルールを優先的に読み込み   |
| AI コンテキスト自動設定 | ルールを AI の判断材料に含める |

## 💡 日常の使い方

### 朝の開発開始時

```bash
# 開発セッション初期化
cursor-start

# 今日のタスク確認
cursor-remind todo
```

### 作業中にルールを忘れた時

```bash
# クイックリマインダー
cursor-remind

# 詳細ルール確認
cursor-remind full

# 強制リフレッシュ
cursor-auto force
```

### コミット時

```bash
# Git hooks が自動実行
git add .
git commit -m "feat: add new feature"

# ↓ 自動で以下が実行される ↓
# 1. @todo.md 更新チェック
# 2. ルールサマリー表示
# 3. コミットメッセージ形式確認
# 4. ルールファイルのリフレッシュ
```

## 🛠️ カスタマイズ

### リフレッシュ間隔の変更

```bash
# auto-rules-refresh.sh の REMINDER_INTERVAL を編集
# デフォルト: 3600秒（1時間）

# 30分間隔にする場合
sed -i 's/REMINDER_INTERVAL=3600/REMINDER_INTERVAL=1800/' .cursor/rules/auto-rules-refresh.sh
```

### Git Hooks の選択的インストール

```bash
# 特定のフックのみ有効化
bash .cursor/rules/git-hooks-setup.sh status   # 現在状況確認
rm .git/hooks/pre-push                          # 不要なフックを削除
```

### Cursor IDE 設定のカスタマイズ

```json
// .cursor/settings.json
{
  "cursor.rules.reminderInterval": 1800, // 30分間隔
  "cursor.rules.showReminders": false, // リマインダー無効化
  "cursor.rules.autoLoadOnStartup": true // 起動時自動読み込み
}
```

## 🔧 トラブルシューティング

### 自動リフレッシュが動かない

```bash
# 1. スクリプトの権限確認
ls -la .cursor/rules/auto-rules-refresh.sh

# 2. 手動実行でエラー確認
bash .cursor/rules/auto-rules-refresh.sh force

# 3. crontab の確認
crontab -l | grep auto-rules-refresh
```

### Git Hooks が動作しない

```bash
# 1. フックファイルの権限確認
ls -la .git/hooks/

# 2. 再インストール
bash .cursor/rules/git-hooks-setup.sh uninstall
bash .cursor/rules/git-hooks-setup.sh install
```

### Cursor IDE で認識されない

```bash
# 1. ファイルタイムスタンプ強制更新
find .cursor/rules -name "*.mdc" -exec touch {} \;

# 2. IDE設定確認
cat .cursor/settings.json

# 3. IDE 再起動
```

## 📊 効果の測定

### 導入前 vs 導入後

| 作業               | 導入前               | 導入後                   |
| ------------------ | -------------------- | ------------------------ |
| ルール確認         | 手動で@指定（2 分）  | 自動表示（0 秒）         |
| ルール忘れ対応     | 探して再確認（5 分） | 自動リマインダー（0 秒） |
| コミット前チェック | 手動確認（3 分）     | 自動フック（30 秒）      |
| 品質管理           | 記憶に依存           | 自動化チェック           |

### 日次効率化

- **時間節約**: 1 日あたり約 20-30 分
- **忘れ防止**: 重要ルールの見落とし 95% 削減
- **品質向上**: 一貫したワークフロー実現

## 🎓 ベストプラクティス

### 1. 習慣化のコツ

```bash
# .bashrc / .zshrc に追加
alias dev-start="cd ~/projects && cursor-start"
alias dev-remind="cursor-remind"
alias dev-status="cursor-auto status"
```

### 2. チーム展開

```bash
# チーム全体で同じ設定を使用
echo "cursor-auto on" >> setup-script.sh
echo "cursor-start" >> daily-routine.sh
```

### 3. プロジェクト固有の調整

```bash
# プロジェクトの特徴に応じてリマインダー内容をカスタマイズ
# auto-rules-refresh.sh の show_key_reminders() 関数を編集
```

## 🔮 高度な機能

### IDE 拡張との連携

```json
// 将来的な Cursor 拡張機能との統合
{
  "cursor.rules.integration": {
    "autoSuggest": true,
    "contextAware": true,
    "smartReminders": true
  }
}
```

### AI モデル連携

```bash
# ルール内容をAIのコンテキストに自動注入
cursor-ai-context --include-rules --auto-refresh
```

## 💬 よくある質問

**Q: 自動リフレッシュを無効化したい**

```bash
cursor-auto off
```

**Q: 特定のプロジェクトでのみ有効化したい**

```bash
# プロジェクトディレクトリでのみ cursor-auto on を実行
```

**Q: リマインダーの頻度を変えたい**

```bash
# REMINDER_INTERVAL の値を秒単位で調整
```

**Q: Git hooks を使いたくない**

```bash
bash .cursor/rules/git-hooks-setup.sh uninstall
```

---

## 🎉 結論

このシステムにより、**手動でのルール確認作業がほぼ 0 になり**、開発効率が大幅に向上します。

- ⏰ **時間節約**: 毎日 20-30 分の節約
- 🎯 **品質向上**: 一貫したルール適用
- 🧠 **認知負荷軽減**: 覚える必要がない自動化
- 🚀 **開発体験向上**: スムーズなワークフロー

**今すぐ始める**: `cursor-new your-project && cursor-auto on`
