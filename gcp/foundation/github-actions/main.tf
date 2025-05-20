locals {
  repositories = var.repositories
}

resource "google_iam_workload_identity_pool" "this" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "github-actions"
}

resource "google_iam_workload_identity_pool_provider" "this" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "github-actions"
  description                        = "OIDC identity pool provider for GitHub Actions"
  attribute_mapping = {
    "attribute.repository" = "assertion.repository"
    "google.subject"       = "assertion.sub"
  }
  attribute_condition = <<EOT
    assertion.repository_owner == "${var.repository_owner}"
EOT
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "this" {
  for_each           = { for repo in local.repositories : "${repo.service_account}/${repo.repository_name}" => repo }
  service_account_id = "projects/${var.gcp_project_id}/serviceAccounts/${each.value.service_account}"
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/projects/${var.gcp_project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.this.workload_identity_pool_id}/attribute.repository/${var.repository_owner}/${each.value.repository_name}"
}




