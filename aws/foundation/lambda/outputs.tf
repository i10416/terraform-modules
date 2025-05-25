output "iam_role" {
  value       = aws_iam_role.this
  description = "AWS IAM role for this lambda"
  depends_on  = []
}

output "function_name" {
  value       = var.function_name
  description = "AWS Lambda function name"
}