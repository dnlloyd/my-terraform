locals {
  role_name = var.create_role ? "EventBridge-${var.bus_name}" : null
}

# IAM role
data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = distinct(concat(["events.amazonaws.com"], var.trusted_entities))
    }
  }
}

resource "aws_iam_role" "eventbridge" {
  count = var.create_role ? 1 : 0

  name                  = local.role_name
  description           = "EventBridge access for ${var.bus_name} bus"
  force_detach_policies = var.role_force_detach_policies
  permissions_boundary  = var.role_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json

  tags = merge({ Name = local.role_name }, local.tags, var.additional_tags, var.role_tags)
}

# X-Ray
data "aws_iam_policy" "tracing" {
  count = var.create_role && var.attach_tracing_policy ? 1 : 0

  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_policy" "tracing" {
  count = var.create_role && var.attach_tracing_policy ? 1 : 0

  name   = "${local.role_name}-tracing"
  policy = data.aws_iam_policy.tracing[0].policy

  tags = merge({ Name = "${local.role_name}-tracing" }, local.tags, var.additional_tags)
}

resource "aws_iam_policy_attachment" "tracing" {
  count = var.create_role && var.attach_tracing_policy ? 1 : 0

  name       = "${local.role_name}-tracing"
  roles      = [aws_iam_role.eventbridge[0].name]
  policy_arn = aws_iam_policy.tracing[0].arn
}

# SQS
data "aws_iam_policy_document" "sqs" {
  count = var.create_role && var.attach_sqs_policy ? 1 : 0

  statement {
    sid    = "SQSAccess"
    effect = "Allow"
    actions = [
      "sqs:SendMessage*",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = var.sqs_target_arns
  }
}

resource "aws_iam_policy" "sqs" {
  count = var.create_role && var.attach_sqs_policy ? 1 : 0

  name   = "${local.role_name}-sqs"
  policy = data.aws_iam_policy_document.sqs[0].json

  tags = merge({ Name = "${local.role_name}-sqs" }, local.tags, var.additional_tags)
}

resource "aws_iam_policy_attachment" "sqs" {
  count = var.create_role && var.attach_sqs_policy ? 1 : 0

  name       = "${local.role_name}-sqs"
  roles      = [aws_iam_role.eventbridge[0].name]
  policy_arn = aws_iam_policy.sqs[0].arn
}

# Lambda
data "aws_iam_policy_document" "lambda" {
  count = var.create_role && var.attach_lambda_policy ? 1 : 0

  statement {
    sid       = "LambdaAccess"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = var.lambda_target_arns
  }
}

resource "aws_iam_policy" "lambda" {
  count = var.create_role && var.attach_lambda_policy ? 1 : 0

  name   = "${local.role_name}-lambda"
  policy = data.aws_iam_policy_document.lambda[0].json

  tags = merge({ Name = "${local.role_name}-lambda" }, local.tags, var.additional_tags)
}

resource "aws_iam_policy_attachment" "lambda" {
  count = var.create_role && var.attach_lambda_policy ? 1 : 0

  name       = "${local.role_name}-lambda"
  roles      = [aws_iam_role.eventbridge[0].name]
  policy_arn = aws_iam_policy.lambda[0].arn
}

# StepFunction
data "aws_iam_policy_document" "sfn" {
  count = var.create_role && var.attach_sfn_policy ? 1 : 0

  statement {
    sid       = "StepFunctionAccess"
    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = var.sfn_target_arns
  }
}

resource "aws_iam_policy" "sfn" {
  count = var.create_role && var.attach_sfn_policy ? 1 : 0

  name   = "${local.role_name}-sfn"
  policy = data.aws_iam_policy_document.sfn[0].json

  tags = merge({ Name = "${local.role_name}-sfn" }, local.tags, var.additional_tags)
}

resource "aws_iam_policy_attachment" "sfn" {
  count = var.create_role && var.attach_sfn_policy ? 1 : 0

  name       = "${local.role_name}-sfn"
  roles      = [aws_iam_role.eventbridge[0].name]
  policy_arn = aws_iam_policy.sfn[0].arn
}

# Cloudwatch 
data "aws_iam_policy_document" "cloudwatch" {
  count = var.create_role && var.attach_cloudwatch_policy ? 1 : 0

  statement {
    sid    = "CloudwatchAccess"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = var.cloudwatch_target_arns
  }
}

resource "aws_iam_policy" "cloudwatch" {
  count = var.create_role && var.attach_cloudwatch_policy ? 1 : 0

  name   = "${local.role_name}-cloudwatch"
  policy = data.aws_iam_policy_document.cloudwatch[0].json

  tags = merge({ Name = "${local.role_name}-cloudwatch" }, local.tags, var.additional_tags)
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  count = var.create_role && var.attach_cloudwatch_policy ? 1 : 0

  name       = "${local.role_name}-cloudwatch"
  roles      = [aws_iam_role.eventbridge[0].name]
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}

# Additional policy (JSON)
resource "aws_iam_policy" "additional_json" {
  count = var.create_role && var.additional_policy_json != null ? 1 : 0

  name   = local.role_name
  policy = var.additional_policy_json

  tags = merge({ Name = local.role_name }, local.tags, var.additional_tags)
}

resource "aws_iam_policy_attachment" "additional_json" {
  count = var.create_role && var.additional_policy_json != null ? 1 : 0

  name       = local.role_name
  roles      = [aws_iam_role.eventbridge[0].name]
  policy_arn = aws_iam_policy.additional_json[0].arn
}

# Additional policies
resource "aws_iam_role_policy_attachment" "additional_many" {
  count = var.create_role && var.additional_policies != null ? length(var.additional_policies) : 0

  role       = aws_iam_role.eventbridge[0].name
  policy_arn = var.additional_policies[count.index]
}
