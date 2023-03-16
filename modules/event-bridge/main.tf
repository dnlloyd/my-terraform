locals {
  eventbridge_rules = flatten([
    for index, rule in var.rules :
    merge(rule, {
      "name" = index
      "Name" = index
    })
  ])
  eventbridge_targets = flatten([
    for index, rule in var.rules : [
      for target in var.targets[index] :
      merge(target, {
        "rule" = index
        "Name" = index
      })
    ] if length(var.targets) != 0
  ])
}

data "aws_cloudwatch_event_bus" "event_bus" {
  count = (var.create_bus) ? 0 : 1

  name = var.bus_name
}

resource "aws_cloudwatch_event_bus" "event_bus" {
  count = var.create_bus ? 1 : 0

  name = var.bus_name
  tags = merge(var.additional_tags, local.tags)
}

resource "aws_schemas_discoverer" "this" {
  count = var.create_schemas_discoverer ? 1 : 0

  source_arn  = var.create_bus ? aws_cloudwatch_event_bus.event_bus[0].arn : data.aws_cloudwatch_event_bus.event_bus[0].arn
  description = var.schemas_discoverer_description

  tags = merge(var.additional_tags, local.tags)
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.eventbridge_rules : v.name => v if var.create_rules }

  name        = each.value.Name
  name_prefix = lookup(each.value, "name_prefix", null)

  event_bus_name = var.create_bus ? aws_cloudwatch_event_bus.event_bus[0].name : var.bus_name

  description         = lookup(each.value, "description", null)
  is_enabled          = lookup(each.value, "enabled", true)
  event_pattern       = lookup(each.value, "event_pattern", null)
  schedule_expression = lookup(each.value, "schedule_expression", null)
  role_arn            = lookup(each.value, "role_arn", null)

  tags = merge(local.tags, var.additional_tags, {
    Name = each.value.Name
  })
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.eventbridge_targets : v.name => v if var.create_targets }

  event_bus_name = var.create_bus ? aws_cloudwatch_event_bus.event_bus[0].name : var.bus_name

  rule = each.value.Name
  arn  = each.value.arn

  role_arn   = lookup(each.value, "role_arn", null)

  target_id  = lookup(each.value, "target_id", null)
  input      = lookup(each.value, "input", null)
  input_path = lookup(each.value, "input_path", null)

  dynamic "run_command_targets" {
    for_each = try([each.value.run_command_targets], [])

    content {
      key    = run_command_targets.value.key
      values = run_command_targets.value.values
    }
  }

  dynamic "sqs_target" {
    for_each = lookup(each.value, "message_group_id", null) != null ? [true] : []

    content {
      message_group_id = each.value.message_group_id
    }
  }

  dynamic "http_target" {
    for_each = lookup(each.value, "http_target", null) != null ? [
      each.value.http_target
    ] : []

    content {
      path_parameter_values   = lookup(http_target.value, "path_parameter_values", null)
      query_string_parameters = lookup(http_target.value, "query_string_parameters", null)
      header_parameters       = lookup(http_target.value, "header_parameters", null)
    }
  }

  dynamic "input_transformer" {
    for_each = lookup(each.value, "input_transformer", null) != null ? [
      each.value.input_transformer
    ] : []

    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  dynamic "dead_letter_config" {
    for_each = lookup(each.value, "dead_letter_arn", null) != null ? [true] : []

    content {
      arn = each.value.dead_letter_arn
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(each.value, "retry_policy", null) != null ? [
      each.value.retry_policy
    ] : []

    content {
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age_in_seconds
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
    }
  }

  depends_on = [aws_cloudwatch_event_rule.this]
}

resource "aws_cloudwatch_event_archive" "this" {
  for_each = var.create_archives ? var.archives : {}

  name             = each.key
  event_source_arn = try(each.value["event_source_arn"], aws_cloudwatch_event_bus.event_bus[0].arn)

  description    = lookup(each.value, "description", null)
  event_pattern  = lookup(each.value, "event_pattern", null)
  retention_days = lookup(each.value, "retention_days", null)
}

resource "aws_cloudwatch_event_bus_policy" "this" {
  count = var.create_event_bus_policy ? 1 : 0

  policy         = var.event_bus_policy
  event_bus_name = aws_cloudwatch_event_bus.event_bus[0].name
}
