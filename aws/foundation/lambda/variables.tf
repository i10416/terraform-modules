# AWS Settings

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID where the Lambda function will be deployed."
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the Lambda function will be deployed."
}


# Lambda Settings
variable "function_name" {
  type        = string
  description = "The name of the Lambda function (without ARN)."
}


variable "tags" {
  type        = map(any)
  default     = {}
  description = "A map of tags to assign to the Lambda function."
}

# Runtime Settings

variable "memory_size" {
  type        = number
  description = "Amount of memory (in MB) allocated to the Lambda function. Default: 1536."
  default     = 1536
}

variable "ephemeral_storage_size" {
  type        = number
  description = "Amount of ephemeral storage (in MB) allocated to the Lambda function. Default: 512."
  default     = 512
}

variable "timeout" {
  type        = number
  description = "Timeout (in seconds) for the Lambda function. Default: 300."
  default     = 300
}

variable "architecture" {
  type        = string
  description = "CPU architecture. One of [`x86_64`, `arm64`]"
  default     = "x86_64"
}

variable "env_vars" {
  type        = map(any)
  default     = {}
  description = "A map of environment variables for the Lambda runtime."
}

# network
variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  nullable    = true
  default     = null
  description = "VPC configuration for the Lambda function (subnet and security group IDs)."
}

# fs
variable "file_system_config" {
  type = object({
    efs_access_point_arn = string
    local_mount_path     = string
  })
  nullable    = true
  default     = null
  description = "EFS configuration for the Lambda function (access point ARN and optional mount path)."
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
  description = "List of schedule expressions to control Lambda invocation."
}


# S3 event trigger
variable "s3_bucket_trigger" {
  type = object({
    source_bucket_arn = string
  })
  nullable    = true
  default     = null
  description = "S3 trigger settings for the Lambda function (source bucket ARN)."
}
