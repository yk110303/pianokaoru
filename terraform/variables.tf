variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "プロジェクト名（リソース名のプレフィックスに使用）"
  type        = string
  default     = "pianokaori"
}

variable "domain_name" {
  description = "カスタムドメイン名（例: pianokaori.com）"
  type        = string
}

variable "to_email" {
  description = "お問い合わせメールの受信先アドレス"
  type        = string
  sensitive   = true
}

variable "from_email" {
  description = "SES で検証済みの送信元メールアドレス"
  type        = string
  sensitive   = true
}
