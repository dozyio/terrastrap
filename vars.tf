variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile from ~/.aws/credentials"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "namespace" {
  description = "Namespace for your infrastructure - lowercase, no symbols, no spaces"
  type        = string
}

variable "env" {
  description = "Environment - lowercase, no symbols, no spaces"
  type        = string
}

variable "tf_lock_dynamodb_table_name" {
  description = "DynamoDB table to store lock"
  type        = string
}

variable "tf_state_s3_bucket" {
  description = "S3 Bucket to store state"
  type        = string
}
