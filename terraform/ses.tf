# ============================================================
# SES: ドメイン認証 + 受信先メールアドレス検証
# ============================================================
# ドメイン認証により noreply@pianokaoru.com など
# @pianokaoru.com アドレスからの送信が可能になります。
# DKIM レコードは Route53 に自動追加されます。
# ============================================================

# pianokaoru.com ドメイン認証（送信元ドメインとして使用）
resource "aws_sesv2_email_identity" "domain" {
  email_identity = var.domain_name

  tags = {
    Project = var.project_name
  }
}

# DKIM レコードを Route53 に追加
resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.site.zone_id
  name    = "${aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
}

# 受信先メールアドレス検証
resource "aws_sesv2_email_identity" "to" {
  email_identity = var.to_email

  tags = {
    Project = var.project_name
  }
}
