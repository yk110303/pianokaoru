# ============================================================
# IAM: Lambda 実行ロール + SES 送信権限
# ============================================================

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_contact" {
  name               = "${var.project_name}-lambda-contact"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Project = var.project_name
  }
}

# CloudWatch Logs への書き込み権限
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_contact.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SES メール送信権限
data "aws_iam_policy_document" "ses_send" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ses_send" {
  name   = "${var.project_name}-ses-send"
  role   = aws_iam_role.lambda_contact.id
  policy = data.aws_iam_policy_document.ses_send.json
}
