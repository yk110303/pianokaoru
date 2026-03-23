# ============================================================
# Lambda: お問い合わせフォーム処理
# ============================================================

# lambda/contact.mjs を zip 化
data "archive_file" "contact" {
  type        = "zip"
  source_file = "${path.root}/../lambda/contact.mjs"
  output_path = "${path.root}/.archive/contact.zip"
}

resource "aws_lambda_function" "contact" {
  function_name    = "${var.project_name}-contact"
  role             = aws_iam_role.lambda_contact.arn
  handler          = "contact.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.contact.output_path
  source_code_hash = data.archive_file.contact.output_base64sha256

  environment {
    variables = {
      TO_EMAIL       = var.to_email
      FROM_EMAIL     = "noreply@${var.domain_name}"
      BCC_EMAIL      = var.bcc_email
      ALLOWED_ORIGIN = "https://${var.domain_name}"
    }
  }

  tags = {
    Project = var.project_name
  }
}

# API Gateway からの呼び出しを許可
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.contact.execution_arn}/*/*"
}
