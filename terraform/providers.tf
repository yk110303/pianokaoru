terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

  # bootstrap/ を先に apply してからコメントを外してください
  backend "s3" {
    bucket         = "pianokaori-tfstate"
    key            = "pianokaori/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "pianokaori-tfstate-lock"
    encrypt        = true
  }
}

# メインリージョン: 東京
provider "aws" {
  region = var.aws_region
}

# CloudFront に紐付ける ACM 証明書は us-east-1 に作成する必要がある
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
