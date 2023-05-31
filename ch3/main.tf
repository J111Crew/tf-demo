terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# Prevent the state bucket from being destroyed
resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-up-and-running-state-maw-2023"
  
#   # for clean up, first remove the terraform block from main.tf and run terraform init
#   # then comment out the lifecycle block below and run terraform destroy.
    lifecycle {
        prevent_destroy = true
    }
}

#Enable versioning on the state bucket so you can see
#the history of changes to the state file
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
        status= "Enabled"
    }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#   for clean up, first remove the terraform block from main.tf and run terraform init
#   then comment out the lifecycle block below and run terraform destroy.
# terraform {
#   backend "s3" {
#     # Replace this with your bucket name!
#     bucket         = "terraform-up-and-running-state-maw-2023"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-2"

#     # Replace this with your DynamoDB table name!
#     dynamodb_table = "terraform-up-and-running-locks"
#     encrypt        = true
#   }
# }
