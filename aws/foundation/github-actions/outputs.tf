
output "assume_role_policy" {
  value       = data.aws_iam_policy_document.this
  description = "aws_iam_policy_document for AWS access from GitHub Actions"
}