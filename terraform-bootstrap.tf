terraform {
  required_version = ">=@TERRAFORM_VERSION"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

module "bootstrap" {
  env                         = var.env
  aws_region                  = var.aws_region
  source                      = "../modules/bootstrap"
  tf_state_s3_bucket          = var.tf_state_s3_bucket
  tf_lock_dynamodb_table_name = var.tf_lock_dynamodb_table_name
  infrastructure_name         = var.infrastructure_name
}

output "bucket_id" {
  value = module.bootstrap.aws_s3_bucket_state_bucket_id
}
output "table_id" {
  value = module.bootstrap.aws_dynamodb_table_id
}
