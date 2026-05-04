# LABEL 装飾クックブック

LABEL フィールドのインライン HTML/CSS 装飾レシピ集。すべて kintone 標準のスタイル前提（customize.css なし）。

## 基本見出し

### 標準セクション見出し（推奨・デフォルト）

```html
<span style="font-size:18px;color:#1976d2;font-weight:bold">📑 識別情報</span>
```

### 大見出し

```html
<span style="font-size:22px;color:#0d47a1;font-weight:bold">🏢 顧客情報</span>
```

### 小見出し / サブセクション

```html
<span style="font-size:16px;color:#1976d2;font-weight:bold">　├ 基本情報</span>
```

## カラーバリエーション

### 青系（通常）

```html
<span style="font-size:18px;color:#1976d2;font-weight:bold">📑 識別情報</span>
<span style="font-size:18px;color:#0d47a1;font-weight:bold">🏢 顧客情報</span>
<span style="font-size:18px;color:#1565c0;font-weight:bold">📋 業務情報</span>
```

### 緑系（成功・完了）

```html
<span style="font-size:18px;color:#2e7d32;font-weight:bold">✅ 完了事項</span>
<span style="font-size:18px;color:#388e3c;font-weight:bold">🎯 達成指標</span>
```

### 赤系（警告・エラー）

```html
<span style="font-size:18px;color:#d32f2f;font-weight:bold">⚠️ 注意事項</span>
<span style="font-size:18px;color:#c62828;font-weight:bold">🚨 緊急対応</span>
```

### 橙系（ハイライト）

```html
<span style="font-size:18px;color:#f57c00;font-weight:bold">💡 ポイント</span>
<span style="font-size:18px;color:#ef6c00;font-weight:bold">🔥 重要</span>
```

### 灰系（補足・メタ）

```html
<span style="font-size:14px;color:#616161">📌 補足情報</span>
<span style="font-size:13px;color:#757575">📝 メタ情報</span>
```

## 装飾パターン

### バッジ風（背景色 + 丸角）

```html
<span style="display:inline-block;padding:4px 12px;background:#1976d2;color:#fff;font-weight:bold;border-radius:4px">📑 識別情報</span>
```

### 左側カラーバー風（border-left）

```html
<span style="display:inline-block;padding:4px 12px;border-left:4px solid #1976d2;font-size:18px;color:#1976d2;font-weight:bold">📑 識別情報</span>
```

### 下線付き

```html
<span style="font-size:18px;color:#1976d2;font-weight:bold;border-bottom:2px solid #1976d2;padding-bottom:2px">📑 識別情報</span>
```

### 二色（アイコン + テキスト違い）

```html
<span style="font-size:18px;color:#1976d2;font-weight:bold">📑</span>
<span style="font-size:18px;color:#424242;font-weight:bold">　識別情報</span>
```

## 情報階層の表現

### 階層見出し

```html
<!-- h1 相当 -->
<span style="font-size:24px;color:#0d47a1;font-weight:bold">🏢 顧客管理</span>

<!-- h2 相当 -->
<span style="font-size:18px;color:#1976d2;font-weight:bold">📑 識別情報</span>

<!-- h3 相当 -->
<span style="font-size:15px;color:#42a5f5;font-weight:bold">└ 基本項目</span>
```

### インライン補足

```html
<span style="font-size:16px;color:#1976d2;font-weight:bold">📑 識別情報</span>
<span style="font-size:12px;color:#999;margin-left:8px">（必須・重複不可）</span>
```

## 説明テキスト

### 注意喚起

```html
<span style="font-size:13px;color:#d32f2f;font-weight:bold">⚠️ 確度が 0.3 未満のナレッジは自動アーカイブされます</span>
```

### 補足説明

```html
<span style="font-size:12px;color:#666;font-style:italic">📌 このセクションは自動入力されます</span>
```

### フォーマット指示

```html
<span style="font-size:12px;color:#757575">📝 形式: YYYY-MM-DD（例: 2026-04-24）</span>
```

## ブランドカラー対応

組織のブランドカラーに合わせたいときの設計指針:

1. **主要セクション**: ブランドメインカラー（例: 企業ブルー `#004098`）
2. **サブセクション**: メインカラーの明度を上げた色（例: `#4a88e8`）
3. **警告・注意**: ブランドに依存しない赤（`#d32f2f`）
4. **成功・完了**: ブランドに依存しない緑（`#2e7d32`）

ブランドカラーで青が使えない場合は、セクション分けに**絵文字の色**で差別化する（📑📝🔗 等の既にカラフルな絵文字を活用）。

## 絵文字ライブラリ

### セクション見出し向け

| カテゴリ | 絵文字 | 用途 |
|---|---|---|
| 識別 | 📑 🆔 🏷️ | ID / タイトル / タグ |
| 内容 | 📝 📄 📋 | 本文 / 概要 |
| 関連 | 🔗 🔀 ↔️ | リンク / 紐付け |
| 分析 | 🔍 🧪 📊 | 問題分析 / 調査 |
| 決定 | ✅ 🎯 ⚡ | 決定事項 / 成果 |
| 状態 | 🎯 📈 📉 | ステータス / 推移 |
| 履歴 | 📜 🕐 📅 | ログ / 時系列 |
| 注意 | ⚠️ 🚨 ❗ | 警告 / 重要 |
| 補足 | 📌 💡 ℹ️ | 補足 / ヒント |
| 品質 | 📊 🎯 ⭐ | メトリクス / 評価 |
| ファイル | 📁 📎 🗃️ | 添付 / 資料 |
| ユーザー | 👤 👥 🏢 | 担当 / 組織 |
| 金額 | 💰 💵 💴 | 価格 / 費用 |
| カレンダー | 📅 🗓️ ⏰ | 日付 / スケジュール |

### 避けたい絵文字

- 顔文字系（😀 😅 等）: 業務文脈で軽薄に見える
- 手指の方向指示（👉 👆 等）: 環境依存で表示崩れ
- 国旗: 地政学的な配慮が必要なケースあり

## 避けるべきパターン

### NG: インライン style に `!important`

```html
<!-- 悪い例 -->
<span style="color:red !important">見出し</span>
```

→ kintone の既存スタイルと競合する。`!important` は最終手段。

### NG: 長すぎる HTML（LABEL が分かれすぎ）

LABEL は概要 1〜2 秒で読めるテキストにする。長い説明は LABEL より、本文フィールドのヘルプテキストに入れる。

### NG: リンクを直書き

```html
<a href="https://example.com">リンク</a>  ← LABEL 内の <a> はクリック不能に見える
```

→ リンクは LINK フィールドで扱う。

### NG: 画像埋め込み

```html
<img src="..." />  ← 対応していない
```

→ 画像は FILE フィールドで扱う。

## セット例: エンタープライズ青系フォーム

```html
<!-- 大見出し -->
<span style="font-size:22px;color:#0d47a1;font-weight:bold">🏢 顧客情報</span>

<!-- 中見出し -->
<span style="font-size:18px;color:#1976d2;font-weight:bold">📑 識別情報</span>
<span style="font-size:18px;color:#1976d2;font-weight:bold">📝 本文</span>
<span style="font-size:18px;color:#1976d2;font-weight:bold">🔗 関連</span>

<!-- 補足 -->
<span style="font-size:13px;color:#757575">📌 このフォームは企業単位で登録</span>

<!-- 警告 -->
<span style="font-size:14px;color:#d32f2f;font-weight:bold">⚠️ 登録後の会社名変更には稟議が必要</span>
```

## セット例: カジュアル緑系フォーム

```html
<span style="font-size:20px;color:#2e7d32;font-weight:bold">🌱 プロダクト登録</span>
<span style="font-size:16px;color:#388e3c;font-weight:bold">📦 基本情報</span>
<span style="font-size:16px;color:#388e3c;font-weight:bold">💡 特徴</span>
<span style="font-size:14px;color:#66bb6a">📌 カテゴリを選んでから詳細を入力してください</span>
```
