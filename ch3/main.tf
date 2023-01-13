resource "aws" {
    region = "us-east-2"
}

# Prevent the state bucket from being destroyed
resource "aws_s3_bucket" "terraform_state_maw_2023" {
    bucket = "terraform_up_and_running_state_maw_2023"
  
    lifecycle {
         prevent_destroy = true
    }
}

#Enable versioning on the state bucket so you can see
#the history of changes to the state file
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state_maw_2023.id

    versioning_configuration {
        enabled = true
    }
}
