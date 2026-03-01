# ============================================================
# SES: メール送信元・受信先のアドレス検証
# ============================================================
# 新規 AWS アカウントは SES がサンドボックスモードのため、
# 検証済みアドレス宛にしかメールを送れません。
# 本番運用では AWS サポートから「本番アクセス」を申請してください。
# ============================================================

resource "aws_sesv2_email_identity" "from" {
  email_identity = var.from_email

  tags = {
    Project = var.project_name
  }
}

resource "aws_sesv2_email_identity" "to" {
  email_identity = var.to_email

  tags = {
    Project = var.project_name
  }
}
