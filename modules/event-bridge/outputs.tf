# EventBridge Bus
output "eventbridge_bus_name" {
  description = "The EventBridge Bus Name"
  value       = var.bus_name
}

output "eventbridge_bus_arn" {
  description = "The EventBridge Bus Arn"
  value       = try(aws_cloudwatch_event_bus.event_bus[0].arn, "")
}

# EventBridge Archive
output "eventbridge_archive_arns" {
  description = "The EventBridge Archive Arns created"
  value       = { for v in aws_cloudwatch_event_archive.this : v.name => v.arn }
}

# EventBridge Rule
output "eventbridge_rule_ids" {
  description = "The EventBridge Rule IDs created"
  value       = { for k in sort(keys(var.rules)) : k => try(aws_cloudwatch_event_rule.this[k].id, null) if var.create_rules }
}

output "eventbridge_rule_arns" {
  description = "The EventBridge Rule ARNs created"
  value       = { for k in sort(keys(var.rules)) : k => try(aws_cloudwatch_event_rule.this[k].arn, null) if var.create_rules }
}
