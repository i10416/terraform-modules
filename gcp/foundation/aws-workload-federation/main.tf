resource "google_iam_workload_identity_pool" "this" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "aws-id-pool"
  display_name              = "AWS id pool"
  description               = "Pool for Workload Identity Federation from AWS"
}

resource "google_iam_workload_identity_pool_provider" "aws_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = "aws-provider"
  display_name                       = "aws_provider"
  description                        = "GCP-AWS Workload Identity Federation"
  aws {
    account_id = var.aws_account_id
  }

  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.account"  = "assertion.account"
    "attribute.aws_role" = "assertion.arn.extract('assumed-role/{role}/')"
  }

  attribute_condition = "attribute.account == '${var.aws_account_id}'"
}

resource "google_service_account_iam_member" "this" {
  for_each           = { for role in var.aws_iam_role_mappings : "${role.aws_iam_role_name}/${role.service_account}" => role }
  service_account_id = each.value.service_account
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.this.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${var.aws_account_id}:assumed-role/${each.value.aws_iam_role_name}"
}