terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "jenkins-terraform-state-822826627239"
    key            = "s3-bucket-infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "my_jenkins_managed_bucket" {
  bucket        = "my-jenkins-managed-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags = {
    Name        = "JenkinsManagedBucket"
    Environment = var.environment_tag
  }
}

resource "aws_s3_bucket_versioning" "my_jenkins_managed_bucket" {
  bucket = aws_s3_bucket.my_jenkins_managed_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "my_jenkins_managed_bucket" {
  bucket                  = aws_s3_bucket.my_jenkins_managed_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket managed by Jenkins Terraform"
  value       = aws_s3_bucket.my_jenkins_managed_bucket.bucket
}
