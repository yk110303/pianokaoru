# ============================================================
# Bootstrap: Terraform State 管理リソース
# ============================================================
# このファイルは terraform/bootstrap/ 配下で一度だけ実行します。
# メインの Terraform 設定を apply する前に必ず実行してください。
#
# 使い方:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply
# ============================================================

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "tfstate_bucket_name" {
  description = "Terraform state を保存する S3 バケット名"
  type        = string
  default     = "pianokaori-tfstate"
}

# tfstate 保存用 S3 バケット
resource "aws_s3_bucket" "tfstate" {
  bucket = var.tfstate_bucket_name
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# state ロック用 DynamoDB テーブル
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "pianokaori-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project = "pianokaori"
  }
}

output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "tfstate_lock_table_name" {
  value = aws_dynamodb_table.tfstate_lock.name
}
