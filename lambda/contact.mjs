/**
 * Lambda: お問い合わせフォーム送信処理
 *
 * === AWSコンソールでの設定手順 ===
 *
 * 1. Lambda関数の作成
 *    - ランタイム: Node.js 20.x
 *    - ハンドラ: contact.handler
 *    - このファイルをzipしてアップロード
 *
 * 2. 環境変数の設定
 *    - TO_EMAIL: 受信先メールアドレス
 *    - FROM_EMAIL: 送信元メールアドレス（SESで検証済みのもの）
 *    - ALLOWED_ORIGIN: CORSで許可するオリジン（例: https://pianokaoru.com）
 *
 * 3. IAMロールにSES送信権限を付与
 *    - ses:SendEmail アクションを許可するポリシーをアタッチ
 *
 * 4. SESでメールアドレスを検証
 *    - FROM_EMAIL と TO_EMAIL の両方を SES で検証
 *    - 本番運用時はSESのサンドボックスを解除
 *
 * 5. API Gatewayの設定
 *    - REST API を作成
 *    - POSTメソッドを作成し、この Lambda を統合
 *    - CORSを有効化（OPTIONSメソッド追加）
 *    - デプロイしてエンドポイントURLを取得
 *    - 取得したURLをフロントエンドの API_ENDPOINT に設定
 */

import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';

const ses = new SESClient();

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': process.env.ALLOWED_ORIGIN || '*',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function respond(statusCode, body) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
    body: JSON.stringify(body),
  };
}

function validate(body) {
  const errors = [];
  if (!body.name || !body.name.trim()) errors.push('名前は必須です');
  if (!body.email || !body.email.trim()) errors.push('メールアドレスは必須です');
  if (body.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(body.email)) {
    errors.push('メールアドレスの形式が正しくありません');
  }
  if (!body.message || !body.message.trim()) errors.push('お問い合わせ内容は必須です');
  return errors;
}

export async function handler(event) {
  // CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return respond(200, { message: 'OK' });
  }

  if (event.httpMethod !== 'POST') {
    return respond(405, { error: 'Method Not Allowed' });
  }

  let body;
  try {
    body = JSON.parse(event.body);
  } catch {
    return respond(400, { error: 'Invalid JSON' });
  }

  const errors = validate(body);
  if (errors.length > 0) {
    return respond(400, { errors });
  }

  const { name, email, phone, message } = body;

  const emailBody = [
    `【pianokaoru お問い合わせ】`,
    ``,
    `お名前: ${name}`,
    `メールアドレス: ${email}`,
    `電話番号: ${phone || '未入力'}`,
    ``,
    `お問い合わせ内容:`,
    message,
  ].join('\n');

  try {
    await ses.send(
      new SendEmailCommand({
        Source: process.env.FROM_EMAIL,
        Destination: { ToAddresses: [process.env.TO_EMAIL] },
        ReplyToAddresses: [email],
        Message: {
          Subject: { Data: `【pianokaori】${name}様からのお問い合わせ`, Charset: 'UTF-8' },
          Body: { Text: { Data: emailBody, Charset: 'UTF-8' } },
        },
      })
    );

    return respond(200, { message: '送信完了' });
  } catch (err) {
    console.error('SES send error:', err);
    return respond(500, { error: 'メール送信に失敗しました' });
  }
}
