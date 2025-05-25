
resource "aws_lambda_function" "this" {
  filename         = data.archive_file.bootstrap.output_path
  function_name    = local.function_arn
  handler          = "bootstrap"
  source_code_hash = data.archive_file.bootstrap.output_base64sha256

  runtime     = "provided.al2023"
  role        = aws_iam_role.this.arn
  memory_size = var.memory_size
  timeout     = var.timeout
  tags        = var.tags
  environment {
    variables = var.env_vars
  }
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? {} : { self = var.vpc_config }
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_config == null ? {} : { self = var.file_system_config }
    content {
      arn              = file_system_config.value.efs_access_point_arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.function_name}"
  tags = var.tags
}

data "archive_file" "bootstrap" {
  type        = "zip"
  source_dir  = "${path.module}/init"
  output_path = "${path.module}/init.zip"
}

# IAM
resource "aws_iam_role" "this" {
  name               = "${var.function_name}-runtime"
  assume_role_policy = file("${path.module}/trust-policies/lambda.json")
  description        = "Allows Lambda functions to call AWS services on your behalf."
}


# Network
# See https://dev.classmethod.jp/articles/tsnote-lambda-the-provided-execution-role-does-not-have-permissions-to-call-createnetworkinterface-on-ec2/
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Schedule
resource "aws_cloudwatch_event_target" "this" {
  for_each  = { for s in var.schedule : s.name => s }
  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "${var.function_name}-${each.key}"
  arn       = aws_lambda_function.this.arn
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each            = { for s in var.schedule : s.name => s }
  name                = "${var.function_name}-${each.key}-schedule"
  description         = each.value.description
  schedule_expression = each.value.expression
  state               = each.value.state
}


resource "random_id" "lambda_permission" {
  for_each    = { for s in var.schedule : s.name => s }
  byte_length = 8
}

resource "aws_lambda_permission" "this" {
  for_each      = { for s in var.schedule : s.name => s }
  statement_id  = "${var.function_name}-schedule-${random_id.lambda_permission[each.key].id}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[each.key].arn
}
# S3 Event Trigger
resource "aws_lambda_permission" "exec_from_s3" {
  count               = var.s3_bucket_trigger == null ? 0 : 1
  source_account      = var.aws_account_id
  source_arn          = var.s3_bucket_trigger.source_bucket_arn
  function_name       = var.function_name
  statement_id_prefix = "${var.function_name}-exec-from-s3"
  action              = "lambda:InvokeFunction"
  principal           = "s3.amazonaws.com"
}
