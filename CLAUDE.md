# pianokaori - ピアノ教室Webサイト

## プロジェクト概要
ピアノ教室「pianokaori」の静的Webサイト。親しみやすく温かみのあるデザイン。

## 技術スタック
- **フレームワーク**: Astro（静的サイト生成）
- **ホスティング**: S3 + CloudFront
- **お問い合わせ**: API Gateway + Lambda + SES
- **フォント**: Noto Sans JP（Google Fonts）
- **言語**: TypeScript（strictest）

## コマンド
- `npm run dev` - 開発サーバー起動
- `npm run build` - 本番ビルド（dist/に出力）
- `npm run preview` - ビルド結果のプレビュー

## ディレクトリ構成
```
src/
  layouts/Layout.astro    # 共通HTMLシェル（head, fonts, Header/Footer）
  components/             # Header.astro, Footer.astro
  pages/                  # index.astro, about.astro, contact.astro
  styles/global.css       # グローバルスタイル
lambda/
  contact.mjs             # お問い合わせ用Lambda関数（SES送信）
public/                   # 静的アセット
```

## デザイン方針
- **カラー**: 白ベース + コーラル系アクセント（`--color-accent: #e8907a`）
- **トーン**: 親しみやすく温かい印象
- **レスポンシブ**: モバイルファースト（ブレークポイント: 768px）
- CSS変数は `src/styles/global.css` の `:root` で定義

## 注意事項
- お問い合わせフォームの `API_ENDPOINT` は `contact.astro` 内で設定（現在は空文字）
- Lambda関数のAWSデプロイ手順は `lambda/contact.mjs` のコメントに記載
- サイトの言語は日本語（`lang="ja"`）
