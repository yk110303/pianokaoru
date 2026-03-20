# ============================================================
# Basic 認証: SSM Parameter Store + CloudFront Function
# ============================================================

# SSM から認証情報を取得（事前に手動で登録しておくこと）
# aws ssm put-parameter --name "/pianokaori/basic-auth" \
#   --value "username:password" --type SecureString --region ap-northeast-1
data "aws_ssm_parameter" "basic_auth" {
  name            = "/${var.project_name}/basic-auth"
  with_decryption = true
}

resource "aws_cloudfront_function" "basic_auth" {
  name    = "${var.project_name}-basic-auth"
  runtime = "cloudfront-js-2.0"
  publish = true

  # SSM の値（user:password）を Base64 エンコードして関数コードに埋め込む
  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var headers = request.headers;
      var expected = "Basic ${base64encode(data.aws_ssm_parameter.basic_auth.value)}";

      if (!headers.authorization || headers.authorization.value !== expected) {
        return {
          statusCode: 401,
          statusDescription: "Unauthorized",
          headers: {
            "www-authenticate": { value: 'Basic realm="${var.project_name}"' }
          }
        };
      }

      // S3 REST API は default_root_object がルートのみ有効なため
      // サブパスの /lesson → /lesson/index.html のようにリライトする
      var uri = request.uri;
      if (uri.endsWith('/')) {
        request.uri = uri + 'index.html';
      } else if (!uri.includes('.')) {
        request.uri = uri + '/index.html';
      }

      return request;
    }
  EOT
}
