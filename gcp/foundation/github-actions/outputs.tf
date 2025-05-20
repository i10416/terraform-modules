output "required_apis" {
  value = [
    # iam.googleapis.com is required to setup workload identity federation
    "iam.googleapis.com",
    # Use secret manager on CI to make it easier to rotate keys in the future
    "secretmanager.googleapis.com",
  ]
  description = "required Google Cloud Platform APIs for this module"
}