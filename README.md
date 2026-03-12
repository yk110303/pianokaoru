# pianokaori

ピアノ教室「pianokaori」の公式Webサイト。

## 技術スタック

| 用途 | 技術 |
|---|---|
| フロントエンド | Astro（静的サイト生成） |
| ホスティング | S3 + CloudFront |
| ドメイン / 証明書 | Route53 + ACM |
| お問い合わせ | API Gateway + Lambda (Node.js 20.x) + SES |
| インフラ管理 | Terraform |
| フォント | Noto Sans JP（Google Fonts） |

## 前提条件

- Node.js 20.x 以上
- AWS CLI（設定済み）
- Terraform 1.6 以上
- Route53 にホストゾーンが作成済みであること

## ローカル開発

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # dist/ に出力
npm run preview    # ビルド結果を確認
```

## インフラのセットアップ（初回）

### 1. tfstate 用リソースの作成

Terraform のステートファイルを S3 で管理するため、最初に一度だけ実行します。

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

### 2. tfvars の作成

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

`terraform/terraform.tfvars` を開き、以下の値を設定します。

```hcl
domain_name = "pianokaori.com"          # カスタムドメイン
to_email    = "your@example.com"        # お問い合わせ受信先
from_email  = "noreply@pianokaori.com"  # SES 送信元（検証済みアドレス）
```

### 3. インフラの適用

```bash
cd terraform
terraform init
terraform apply
```

### 4. お問い合わせフォームの API エンドポイントを設定

```bash
terraform output api_endpoint
```

出力された URL を `src/pages/contact.astro` の `API_ENDPOINT` 定数に設定します。

### 5. SES の本番アクセス申請

新規 AWS アカウントは SES がサンドボックスモードです。
本番運用前に AWS サポートから「本番アクセス（Production Access）」を申請してください。

## デプロイ

```bash
# 1. ビルド
npm run build

# 2. S3 へアップロード
aws s3 sync dist/ s3://pianokaori.com/ --delete

# 3. CloudFront キャッシュをクリア
aws cloudfront create-invalidation \
  --distribution-id $(cd terraform && terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

## インフラ構成図

```
ユーザー
  │
  ▼
Route53 (DNS)
  │
  ▼
CloudFront (HTTPS, キャッシュ)
  │
  ├─▶ S3 (静的ファイル配信)
  │
  └─ ※ CloudFront は静的ファイルのみ。API は直接 API Gateway へ
       ↓
フォーム送信
  │
  ▼
API Gateway (POST /contact)
  │
  ▼
Lambda (Node.js)
  │
  ▼
SES (メール送信)
```

## ディレクトリ構成

```
src/
  layouts/Layout.astro    # 共通HTMLシェル
  components/             # Header.astro, Footer.astro
  pages/                  # index.astro, contact.astro
  styles/global.css       # グローバルスタイル・CSS変数
lambda/
  contact.mjs             # お問い合わせ Lambda 関数
terraform/
  bootstrap/              # tfstate 管理リソース（初回のみ）
  *.tf                    # インフラ定義
public/
  images/                 # 画像ファイル
```
