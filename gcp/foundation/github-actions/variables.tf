variable "gcp_project_id" {
  type        = string
  description = "GCP project id"
}
variable "gcp_project_number" {
  type        = string
  description = "GCP project number. You can find it at https://console.cloud.google.com/iam-admin/settings"
}
variable "repository_owner" {
  type    = string
}

variable "repositories" {
  type = list(object({
    service_account = string
    repository_name = string
  }))
  description = "a list of repository and service account email"
}




