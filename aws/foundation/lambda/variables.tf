# AWS Settings

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}


# Lambda Settings
variable "function_name" {
  type        = string
  description = "lambda function name without arn"
}


variable "tags" {
  type        = map(any)
  default     = {}
  description = "lambda tags"
}

# Runtime Settings

variable "memory_size" {
  type        = number
  description = "memory size to be allocated"
  default     = 1536
}

variable "ephemeral_storage_size" {
  type        = number
  description = "ephemeral storage size"
  default     = 512
}

variable "timeout" {
  type        = number
  description = "lambda timeout"
  default     = 300
}

variable "env_vars" {
  type        = map(any)
  default     = {}
  description = "lambda runtime environment variables"
}

# network
variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  nullable    = true
  default     = null
  description = "Lambda VPC Config"
}

# fs
variable "file_system_config" {
  type = object({
    efs_access_point_arn = string
    local_mount_path     = optional(string, "/mnt/efs")
  })
  nullable    = true
  default     = null
  description = "Lambda EFS config"
}

# Schedule

variable "schedule" {
  type = list(object({
    name        = string
    expression  = string
    description = string
    state       = optional(string, "DISABLED")
  }))
  default     = []
  description = "schedule expression to control lambda invocation"
}


# S3 event trigger
variable "s3_bucket_trigger" {
  type = object({
    source_bucket_arn = string
  })
  nullable    = true
  default     = null
  description = "s3 trigger settings"
}