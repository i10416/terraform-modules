
variable "repository_owner" {
  type    = string
  description = "GitHub owner name"
}

variable "repositories" {
  type = list(object({
    role_name       = string
    repository_name = string
  }))
  description = "a list of pairs of role_name and repositories"
}



