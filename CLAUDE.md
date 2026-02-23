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
  pages/                  # index.astro, contact.astro
  styles/global.css       # グローバルスタイル
lambda/
  contact.mjs             # お問い合わせ用Lambda関数（SES送信）
public/                   # 静的アセット
```

## デザイン方針
- **カラー**: ベージュ・ブラウン系（温かみのある落ち着いたトーン）
- **トーン**: 親しみやすく温かい印象
- **レスポンシブ**: モバイルファースト（ブレークポイント: 768px）
- CSS変数は `src/styles/global.css` の `:root` で定義

### CSS変数一覧
```css
--color-bg: #faf9f7          /* メイン背景（温かみのある白） */
--color-bg-light: #f5f0eb    /* セクション背景（ベージュ系）*/
--color-text: #38342e        /* メインテキスト（ダークブラウン系）*/
--color-text-light: #5b5751  /* サブテキスト */
--color-accent: #78683b      /* アクセント（ゴールデンブラウン）*/
--color-accent-hover: #5c5030
--color-accent-light: #b6b1aa
--color-border: #e8e0da      /* ボーダー */
--font-family: 'Noto Sans JP', sans-serif
--max-width: 1100px
--header-height: 72px
```

### セクション背景パターン
| セクション | 背景 |
|---|---|
| Hero | `::before` に `catch-bg.jpg`（パララックス）、`::after` に `linear-gradient` オーバーレイ |
| Message | `--color-bg` |
| Policy | `--color-bg-light` |
| Commitment | `--color-bg` |
| Lesson | `--color-bg-light` |
| Chiku | `::before` に `tiiku01.jpg`（ぼかし + パララックス）、`::after` に白オーバーレイ |
| Profile | `--color-bg` |
| SNS | `--color-bg-light` + `sns-bg.png`（背景画像）|
| Access | `--color-bg-light` |
| Intro（CTA） | `--color-bg` |

### ボタン種類
- `.btn-primary` — ゴールデンブラウン塗りつぶし（主要CTA）
- `.btn-outline` — 白背景 + ゴールデンブラウン枠線（サブCTA）、hover で塗りつぶしに変化
- `.btn-line` — LINE グリーン（`#06C755`）
- 共通: `border-radius: 40px`（ピル形状）、hover で `translateY(-1px)`

### セクションタイトル装飾
`.section-title` は両サイドに短い横線（`::before`/`::after`）を表示。日本語タイトル + 英語サブタイトル（`.section-subtitle`）のセット。

### アニメーション
- **ローダー**: トップページ初回訪問時のみ音符（♩♪♫♬）がバウンスイン → 1.2秒後にフェードアウト。`sessionStorage` で2回目以降はスキップ。
- **ホバー**: カード類は `translateY(-4px)`、ボタンは `translateY(-1px)`
- **ヘッダーナビ**: アクティブ・ホバー時にアクセントカラーの下線がスライドイン
- **モバイルメニュー**: スライドダウン + 背景オーバーレイ（`backdrop-filter: blur(8px)`）
- **パララックス**: Hero・Chiku セクションの背景が JS スクロールイベントで `--parallax-y` CSS変数を更新し `translateY` でゆっくり移動（スクロール量の 20%）

### 画像ファイル（`public/images/`）
| ファイル | 用途 |
|---|---|
| `catch-bg.jpg` | Hero背景 |
| `sns-bg.png` | SNSセクション背景 |
| `feature-lesson.png` | 特徴カード①アイコン（200×200px表示）|
| `feature-music.png` | 特徴カード②アイコン |
| `feature-room.png` | 特徴カード③アイコン |
| `lesson-01.png` ～ `lesson-04.png` | レッスンカードヘッダー背景（右寄せ）|

## ページ構成（`index.astro`のセクション順）
1. **Hero** — キャッチコピー + CTA（お問い合わせ / LINE）
2. **About** — プロフィール文 + 3つのフィロソフィー（01〜03）
3. **Features** — 教室の特徴 3カラムグリッド
4. **Lesson** — 4種コース料金表（通常 / 中学生以上 / 知育プラス / 大人単発）
5. **SNS** — Instagram / Ameba Blog リンクカード
6. **Access** — 住所・アクセス情報（練馬区下石神井5丁目）
7. **Intro（CTA）** — 締めのメッセージ + ボタン

## 注意事項
- **ヘッダー**: トップページはスクロールで `.scrolled` クラスが付く（透明 → 白背景）。サブページは `.hero` 要素がないため初期から `.scrolled` 状態で表示。
- お問い合わせページはLINEとメールフォームの2択（`contact.astro`）
  - LINEのQRコード画像・URLは未設定（TODO）
  - メールフォームの `API_ENDPOINT` は `contact.astro` 内で設定（現在は空文字）
- Lambda関数のAWSデプロイ手順は `lambda/contact.mjs` のコメントに記載
- サイトの言語は日本語（`lang="ja"`）
- SNSリンク（Instagram・Ameba Blog）は `href="#"` のプレースホルダー（TODO）
