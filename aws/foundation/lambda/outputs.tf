output "iam_role" {
  value       = aws_iam_role.this
  description = "The AWS IAM role created for this Lambda function."
  depends_on  = []
}

output "function_name" {
  value       = var.function_name
  description = "The name of the AWS Lambda function."
}
