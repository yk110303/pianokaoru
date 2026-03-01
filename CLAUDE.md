# pianokaori - ピアノ教室Webサイト

## Claude へのルール
- 編集によってこのファイルの内容に変更が生じた場合、**作業完了後に必ず CLAUDE.md を更新すること**

## プロジェクト概要
ピアノ教室「pianokaori」の静的Webサイト。親しみやすく温かみのあるデザイン。

## 技術スタック
- **フレームワーク**: Astro（静的サイト生成）
- **ホスティング**: S3 + CloudFront（Route53 + ACM でカスタムドメイン）
- **お問い合わせ**: API Gateway (HTTP API) + Lambda (Node.js 20.x) + SES
- **インフラ管理**: Terraform（tfstate は S3 バックエンド + DynamoDB ロック）
- **フォント**: Noto Sans JP（Google Fonts）
- **言語**: TypeScript（strictest）

## コマンド

### フロントエンド
- `npm run dev` - 開発サーバー起動
- `npm run build` - 本番ビルド（dist/に出力）
- `npm run preview` - ビルド結果のプレビュー

### Terraform
```bash
# 初回のみ: tfstate 用リソースを作成
cd terraform/bootstrap && terraform init && terraform apply

# メインインフラの適用
cd terraform && terraform init && terraform apply

# デプロイ（ビルド → S3同期 → CloudFrontキャッシュクリア）
npm run build
aws s3 sync dist/ s3://<domain_name>/ --delete
aws cloudfront create-invalidation --distribution-id $(terraform output -raw cloudfront_distribution_id) --paths "/*"
```

## ディレクトリ構成
```
src/
  layouts/Layout.astro    # 共通HTMLシェル（head, fonts, Header/Footer）
  components/             # Header.astro, Footer.astro
  pages/                  # index.astro, lesson.astro, profile.astro, contact.astro
  styles/global.css       # グローバルスタイル
lambda/
  contact.mjs             # お問い合わせ用Lambda関数（SES送信）
terraform/
  bootstrap/main.tf       # tfstate用S3+DynamoDB（初回のみ実行）
  providers.tf            # AWSプロバイダー + S3バックエンド設定
  variables.tf            # 入力変数（domain_name, to_email, from_email）
  outputs.tf              # 出力値（site_url, api_endpoint, s3_bucket_name など）
  s3.tf                   # 静的サイト用S3バケット
  cloudfront.tf           # CloudFrontディストリビューション（OAC使用）
  acm.tf                  # SSL証明書（us-east-1 で作成）+ DNS検証
  route53.tf              # A/AAAAレコード（apex + www）
  iam.tf                  # Lambda実行ロール + SES送信権限
  lambda.tf               # お問い合わせLambda（archive_fileでzip化）
  api_gateway.tf          # HTTP API（POST /contact）
  ses.tf                  # 送受信メールアドレス検証
  terraform.tfvars.example
public/                   # 静的アセット
```

## デザイン方針
- **カラー**: ベージュ・ブラウン系（温かみのある落ち着いたトーン）
- **トーン**: 親しみやすく温かい印象
- **レスポンシブ**: モバイルファースト（ブレークポイント: 768px）
- CSS変数は `src/styles/global.css` の `:root` で定義

### CSS変数一覧
```css
--color-bg: #ffffff          /* メイン背景（白） */
--color-bg-dark: #f5f0eb     /* セクション背景（ベージュ系）*/
--color-text: #38342e        /* メインテキスト（ダークブラウン系）*/
--color-text-light: #5b5751  /* サブテキスト */
--color-accent: #78683b      /* アクセント（ゴールデンブラウン） */
--color-accent-hover: #5c5030
--color-accent-light: #b6b1aa
--color-border: #e8e0da      /* ボーダー */
--color-chiku: #6a9e46       /* 知育アクセント（黄緑・フォント用） */
--color-chiku-hover: #527a34 /* 知育ホバー */
--color-chiku-light: #e8f3dc /* 知育背景（薄い黄緑） */
--font-family: 'Noto Sans JP', sans-serif
--max-width: 1100px
--header-height: 72px
```

### セクション背景パターン
| セクション | 背景 |
|---|---|
| Hero | `::before` に `classroom02.jpg`（パララックス）、`::after` に `linear-gradient` オーバーレイ |
| Message | `--color-bg` |
| Policy | `--color-bg-dark` |
| Commitment | `--color-bg` |
| Lesson | `--color-bg-dark`（`/lesson` ページ） |
| Chiku | `::before` に `tiiku-bg.jpg`（ぼかし + パララックス）、`::after` に白オーバーレイ |
| Profile | `--color-bg`（`/profile` ページ） |
| SNS | `--color-bg-dark` + `sns-bg.png`（背景画像）|
| Access | `--color-bg-dark` |
| Intro（CTA） | `--color-bg` |

### ボタン種類
- `.btn-primary` — ゴールデンブラウン塗りつぶし（主要CTA）
- `.btn-outline` — 白背景 + ゴールデンブラウン枠線（サブCTA）、hover で塗りつぶしに変化
- `.btn-line` — LINE グリーン（`#06C755`）
- 共通: `border-radius: 40px`（ピル形状）、hover で `translateY(-1px)`

### セクションタイトル装飾
`.section-title` は両サイドに短い横線（`::before`/`::after`）を表示。日本語タイトル + 英語サブタイトル（`.section-subtitle`）のセット。
- `.section-subtitle` の色は `--color-accent-light`

### その他スタイル
- `.gradient-text` — レインボーグラデーションテキスト（Policy の「ピティナ・ステップ」に使用）

### アニメーション
- **ローダー**: トップページ初回訪問時のみ音符（♩♪♫♬）がバウンスイン → 1.2秒後にフェードアウト。`sessionStorage` で2回目以降はスキップ。
- **ホバー**: カード類は `translateY(-4px)`、ボタンは `translateY(-1px)`
- **ヘッダーナビ**: アクティブ・ホバー時にアクセントカラーの下線がスライドイン
- **モバイルメニュー**: スライドダウン + 背景オーバーレイ（`backdrop-filter: blur(8px)`）
- **パララックス**: Hero・Chiku セクションの背景が JS スクロールイベントで `--parallax-y` CSS変数を更新し `translateY` でゆっくり移動（スクロール量の 20%）

### 画像ファイル（`public/images/`）
| ファイル | 用途 |
|---|---|
| `lesson-cache-bg.jpg` | レッスン案内ページのキャッチ背景 |
| `sns-bg.png` | SNSセクション背景 |
| `feature-lesson.png` | 特徴カード①アイコン（200×200px表示）|
| `feature-music.png` | 特徴カード②アイコン |
| `feature-room.png` | 特徴カード③アイコン |
| `tiiku-bg.jpg` | 知育セクション背景（専用画像）|
| `tiiku01.jpg` | 知育セクション内カード画像 |
| `lesson-01.png` ～ `lesson-04.png` | 未使用（削除済み）|

## ページ構成

### `index.astro`（`/`）のセクション順
1. **Hero** — キャッチコピー + CTA（お問い合わせ / LINE）（`margin: 0 20px`・`border-radius: 20px`・上マージンなし）
2. **Message** — メッセージ
3. **Policy** — レッスン方針（`policy-pickup` カードに「ピティナ・ステップの推奨」小見出し付き）
4. **Commitment** — 講師のこだわり（01〜02）
5. **Chiku** — 松田知育ピアノメソッドコース（`chiku-card` max-width: 900px、`margin: 0 20px 20px`・`border-radius: 20px`）
6. **SNS** — Instagram / Ameba Blog リンクカード
7. **Access** — 住所・アクセス情報（練馬区下石神井5丁目）
8. **Intro（CTA）** — 締めのメッセージ + ボタン

### 独立ページ
- **`lesson.astro`（`/lesson`）** — レッスン案内（4種コース料金表：通常 / 中学生以上 / 知育プラス / 大人単発）
- **`profile.astro`（`/profile`）** — プロフィール・資格（渡部 薫）
- **`contact.astro`（`/contact`）** — お問い合わせ（LINE / メールフォーム）

サブページ（lesson / profile / contact）は `.page-header` / `.page-title` / `.page-subtitle` を共通で使用（`global.css` で定義）。

## 注意事項
- **ヘッダー**: トップページはスクロールで `.scrolled` クラスが付く（透明 → 白背景）。サブページは `.hero` 要素がないため初期から `.scrolled` 状態で表示。
- お問い合わせページはLINEとメールフォームの2択（`contact.astro`）
  - LINEのQRコード画像・URLは未設定（TODO）
  - メールフォームの `API_ENDPOINT` は `contact.astro` 内で設定（`terraform output api_endpoint` の値を使う）
- Lambda は Terraform の `archive_file` で zip 化して自動デプロイされる
- SES は新規 AWS アカウントだとサンドボックスモード。本番運用前に AWS サポートへ「本番アクセス」を申請すること
- API Gateway の payload_format_version は `1.0`（Lambda 内で `event.httpMethod` を使うため）
- Terraform の設定値（メールアドレス等）は `terraform/terraform.tfvars` に記述し、`.gitignore` で除外済み
- Route53 のホストゾーンは Terraform 管理外（事前に作成しておくこと）
- サイトの言語は日本語（`lang="ja"`）
- SNSリンク（Instagram・Ameba Blog）は `href="#"` のプレースホルダー（TODO）
