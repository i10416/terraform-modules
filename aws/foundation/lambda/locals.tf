locals {
  function_arn = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.function_name}"
}