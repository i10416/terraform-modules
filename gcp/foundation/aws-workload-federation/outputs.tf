output "required_apis" {
  value = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ]
  description = "required Google Cloud Platform APIs for this module"
}

