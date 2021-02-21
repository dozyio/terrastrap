# Module to build the Terraform DynamoDB bootstrap for remote state lock

resource "aws_dynamodb_table" "tf_lock_state" {
  name = "${var.env}-${var.infrastructure_name}-${var.aws_region}-${var.tf_lock_dynamodb_table_name}"

  billing_mode = "PAY_PER_REQUEST"

  # Hash key needs to be LockID for terraform
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Terraform = "true"
    Env       = var.env
    Bootstrap = "true"
  }
}

output "aws_dynamodb_table_id" {
  value = aws_dynamodb_table.tf_lock_state.id
}
