
output "assume_role_policy" {
  value       = data.aws_iam_policy_document.this
  description = "aws_iam_policy_document for AWS access from GitHub Actions"
}

output "assume_role_policy_per_role" {
  value       = data.aws_iam_policy_document.per_role
  description = "aws_iam_policy_document for AWS access from GitHub Actions"
}