# ============================================================
# CloudFront Function: サブパスの URI リライト
# /lesson → /lesson/index.html のように補完する
# ============================================================

resource "aws_cloudfront_function" "url_rewrite" {
  name    = "${var.project_name}-url-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<-EOT
    function handler(event) {
      var uri = event.request.uri;
      if (uri.endsWith('/')) {
        event.request.uri = uri + 'index.html';
      } else if (!uri.includes('.')) {
        event.request.uri = uri + '/index.html';
      }
      return event.request;
    }
  EOT
}
