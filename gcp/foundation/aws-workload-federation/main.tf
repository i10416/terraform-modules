locals {
  aws_iam_role_mappings_group = {
    for item in var.aws_iam_role_mappings : item.aws_account_id => {
      aws_iam_role_name = item.aws_iam_role_name
      service_account   = item.service_account
    }...
  }
}
resource "google_iam_workload_identity_pool" "this" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "aws-id-pool"
  display_name              = "AWS id pool"
  description               = "Pool for Workload Identity Federation from AWS"
}

resource "google_iam_workload_identity_pool_provider" "aws_provider" {
  for_each                           = local.aws_iam_role_mappings_group
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = "aws-provider"
  display_name                       = "aws_provider"
  description                        = "GCP-AWS Workload Identity Federation"
  aws {
    account_id = each.key
  }

  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.account"  = "assertion.account"
    "attribute.aws_role" = "assertion.arn.extract('assumed-role/{role}/')"
  }

  attribute_condition = "attribute.account == '${var.aws_account_id}'"
}

resource "google_service_account_iam_member" "this" {
  for_each = merge(
    [for _, mappings in local.aws_iam_role_mappings_group :
      { for m in mappings : "${m.aws_iam_role_name}/${m.service_account}" => m }
    ]...
  )
  service_account_id = each.value.service_account
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.this.workload_identity_pool_id}/attribute.aws_role/${each.value.aws_iam_role_name}"
}
