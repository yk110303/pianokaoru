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
  description = "廃止予定: 送信元は noreply@<domain_name> に固定。tfvars から削除可能"
  type        = string
  sensitive   = true
  default     = ""
}

variable "bcc_email" {
  description = "お問い合わせメールの BCC 先アドレス（管理用。空文字列で無効）"
  type        = string
  sensitive   = true
  default     = ""
}
