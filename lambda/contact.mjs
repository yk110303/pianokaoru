/**
 * Lambda: お問い合わせフォーム送信処理
 *
 * 環境変数:
 *   TO_EMAIL       - 受信先メールアドレス（教室側）
 *   FROM_EMAIL     - 送信元メールアドレス（SES で認証済みドメイン: noreply@pianokaoru.com）
 *   BCC_EMAIL      - BCC 先メールアドレス（管理用。空文字列で無効）
 *   ALLOWED_ORIGIN - CORS で許可するオリジン
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
  const fromEmail = process.env.FROM_EMAIL;
  const toEmail = process.env.TO_EMAIL;
  const bccEmail = process.env.BCC_EMAIL;

  // 教室側への通知メール本文
  const notifyBody = [
    `【pianokaoru お問い合わせ】`,
    ``,
    `お名前: ${name}`,
    `メールアドレス: ${email}`,
    `電話番号: ${phone || '未入力'}`,
    ``,
    `お問い合わせ内容:`,
    message,
  ].join('\n');

  // 送信者への自動返信メール本文
  const replyBody = [
    `${name} 様`,
    ``,
    `この度はお問い合わせいただきありがとうございます。`,
    `渡部かおるピアノ教室です。`,
    ``,
    `以下の内容でお問い合わせを受け付けいたしました。`,
    `内容を確認のうえ、折り返しご連絡いたします。`,
    ``,
    `─────────────────────`,
    `お名前: ${name}`,
    `メールアドレス: ${email}`,
    `電話番号: ${phone || '未入力'}`,
    ``,
    `お問い合わせ内容:`,
    message,
    `─────────────────────`,
    ``,
    `※このメールは自動送信されています。`,
    `  このメールへの返信はできませんのでご了承ください。`,
    ``,
    `渡部かおるピアノ教室`,
    `https://pianokaoru.com`,
  ].join('\n');

  try {
    // 教室側への通知メール送信
    const destination = {
      ToAddresses: [toEmail],
      ...(bccEmail ? { BccAddresses: [bccEmail] } : {}),
    };

    await ses.send(
      new SendEmailCommand({
        Source: fromEmail,
        Destination: destination,
        ReplyToAddresses: [email],
        Message: {
          Subject: { Data: `【pianokaoru】${name}様からのお問い合わせ`, Charset: 'UTF-8' },
          Body: { Text: { Data: notifyBody, Charset: 'UTF-8' } },
        },
      })
    );

    // 送信者への自動返信
    await ses.send(
      new SendEmailCommand({
        Source: fromEmail,
        Destination: { ToAddresses: [email] },
        Message: {
          Subject: { Data: `【渡部かおるピアノ教室】お問い合わせを受け付けました`, Charset: 'UTF-8' },
          Body: { Text: { Data: replyBody, Charset: 'UTF-8' } },
        },
      })
    );

    return respond(200, { message: '送信完了' });
  } catch (err) {
    console.error('SES send error:', err);
    return respond(500, { error: 'メール送信に失敗しました' });
  }
}
