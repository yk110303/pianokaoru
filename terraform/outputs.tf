output "site_url" {
  description = "サイト URL"
  value       = "https://${var.domain_name}"
}

output "cloudfront_domain" {
  description = "CloudFront ディストリビューションのドメイン名"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront ディストリビューション ID（キャッシュ削除に使用）"
  value       = aws_cloudfront_distribution.site.id
}

output "s3_bucket_name" {
  description = "静的サイト配置用 S3 バケット名"
  value       = aws_s3_bucket.site.bucket
}

output "api_endpoint" {
  description = "お問い合わせフォームの API エンドポイント URL（contact.astro の API_ENDPOINT に設定する）"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/contact"
}
