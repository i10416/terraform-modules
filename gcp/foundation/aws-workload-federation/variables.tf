variable "gcp_project_id" {
  type        = string
  description = "GCP project id"
}
variable "gcp_project_number" {
  type        = string
  description = "GCP project number. You can find it at https://console.cloud.google.com/iam-admin/settings"
}

variable "aws_account_id" {
  type = string
  description = "AWS account ID"
}

variable "aws_iam_role_mappings" {
  type = list(object({
    aws_iam_role_name = string
    service_account = string
  }))
  description = "a list of aws_iam_role and service account email"
}


