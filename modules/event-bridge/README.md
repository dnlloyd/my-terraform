# AWS EventBridge Terraform module

Terraform module to create EventBridge resources

## Production Versions History

| Version | Release Notes |
|---------|---------------|
|  0.1.0  | Initial release |

## Usage

### Example

```hcl
module "eventbridge" {
  source = "../../"

  bus_name = "my-bus"

  cross_account_ids = ["123456789012", "210987654321"]

  attach_sfn_policy = true
  sfn_target_arns   = [var.my_step_function_arn]

  attach_sqs_policy = true
  sqs_target_arns   = [aws_sqs_queue.queue.arn]

  attach_cloudwatch_policy = true
  cloudwatch_target_arns   = [aws_cloudwatch_log_group.this.arn]

  rules = {
    orders = {
      description   = "Capture all order data"
      event_pattern = jsonencode({ "source" : ["myapp.orders"] })
      enabled       = false
    }
    emails = {
      description   = "Capture all emails data"
      event_pattern = jsonencode({ "source" : ["myapp.emails"] })
      enabled       = true
    }
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = "rate(5 minutes)"
    }
  }

  targets = {
    orders = [
      {
        name              = "send-orders-to-sqs"
        arn               = aws_sqs_queue.queue.arn
        input_transformer = local.order_input_transformer
      },
      {
        name = "log-orders-to-cloudwatch"
        arn  = aws_cloudwatch_log_group.this.arn
      }
    ]

    emails = [
      {
        name            = "process-email-with-sfn"
        arn             = var.my_step_function_arn
        attach_role_arn = true
      }
    ]

    crons = [
      {
        name  = "something-for-cron"
        arn   = var.my_lambda_function_arn
        input = jsonencode({ "job" : "crons" })
      }
    ]
  }

  additional_policy_json = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:GetSamplingStatisticSummaries"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:GetSamplingRules"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:ListResourcePolicies"
        ],
        "Resource" : ["*"]
      }
    ]
  })

  additional_policies = ["arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"]

  purpose      = "test"
  itcontact    = "test"
  costcenter   = "1234567"
  businessline = "test"
  environment  = "Development"
}

locals {
  order_input_transformer = {
    input_paths = {
      order_id = "$.detail.order_id"
    }
    input_template = <<EOF
    {
      "id": <order_id>
    }
    EOF
  }
}

```

### Testing cross account access to bus

From an external AWS account:

```
aws events put-events --entries file://my-event.json
```

my-event.json
```
[
  {
    "Source": "test.app",
    "Detail": "{ \"key1\": \"value1\", \"key2\": \"value2\" }",
    "Resources": [
      "resource1",
      "resource2"
    ],
    "DetailType": "myDetailType",
    "EventBusName": "arn:aws:events:us-east-1:<ACCOUNT ID>:event-bus/default"
  }
]
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.7 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_archive.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_archive) | resource |
| [aws_cloudwatch_event_bus.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_permission) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.additional_json](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.tracing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.additional_json](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.tracing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional_many](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_schemas_discoverer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/schemas_discoverer) | resource |
| [aws_cloudwatch_event_bus.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_event_bus) | data source |
| [aws_iam_policy.tracing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policies"></a> [additional\_policies](#input\_additional\_policies) | List of policy statements ARN to attach to IAM role | `list(string)` | `null` | no |
| <a name="input_additional_policy_json"></a> [additional\_policy\_json](#input\_additional\_policy\_json) | An additional policy document as JSON to attach to IAM role | `string` | `null` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | A map of additional tags. Required tags are set as mandatory variables | `map(any)` | `{}` | no |
| <a name="input_archives"></a> [archives](#input\_archives) | A map of objects with the EventBridge Archive definitions. | `map(any)` | `{}` | no |
| <a name="input_attach_cloudwatch_policy"></a> [attach\_cloudwatch\_policy](#input\_attach\_cloudwatch\_policy) | Controls whether the Cloudwatch policy should be added to IAM role for EventBridge Target | `bool` | `false` | no |
| <a name="input_attach_lambda_policy"></a> [attach\_lambda\_policy](#input\_attach\_lambda\_policy) | Controls whether the Lambda Function policy should be added to IAM role for EventBridge Target | `bool` | `false` | no |
| <a name="input_attach_sfn_policy"></a> [attach\_sfn\_policy](#input\_attach\_sfn\_policy) | Controls whether the StepFunction policy should be added to IAM role for EventBridge Target | `bool` | `false` | no |
| <a name="input_attach_sqs_policy"></a> [attach\_sqs\_policy](#input\_attach\_sqs\_policy) | Controls whether the SQS policy should be added to IAM role for EventBridge Target | `bool` | `false` | no |
| <a name="input_attach_tracing_policy"></a> [attach\_tracing\_policy](#input\_attach\_tracing\_policy) | Controls whether X-Ray tracing policy should be added to IAM role for EventBridge | `bool` | `false` | no |
| <a name="input_bus_name"></a> [bus\_name](#input\_bus\_name) | A unique name for your EventBridge Bus | `string` | `"default"` | no |
| <a name="input_businessline"></a> [businessline](#input\_businessline) | Business Line responsible for resource ownership | `string` | n/a | yes |
| <a name="input_cloudwatch_target_arns"></a> [cloudwatch\_target\_arns](#input\_cloudwatch\_target\_arns) | The Amazon Resource Name (ARN) of the Cloudwatch Log Streams you want to use as EventBridge targets | `list(string)` | `[]` | no |
| <a name="input_costcenter"></a> [costcenter](#input\_costcenter) | Seven digits number of the Cost Center for resource ownership | `string` | n/a | yes |
| <a name="input_create_archives"></a> [create\_archives](#input\_create\_archives) | Controls whether EventBridge Archive resources should be created | `bool` | `false` | no |
| <a name="input_create_bus"></a> [create\_bus](#input\_create\_bus) | Controls whether EventBridge Bus resource should be created | `bool` | `true` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Controls whether IAM roles should be created | `bool` | `true` | no |
| <a name="input_create_rules"></a> [create\_rules](#input\_create\_rules) | Controls whether EventBridge Rule resources should be created | `bool` | `true` | no |
| <a name="input_create_schemas_discoverer"></a> [create\_schemas\_discoverer](#input\_create\_schemas\_discoverer) | Controls whether default schemas discoverer should be created | `bool` | `false` | no |
| <a name="input_create_targets"></a> [create\_targets](#input\_create\_targets) | Controls whether EventBridge Target resources should be created | `bool` | `true` | no |
| <a name="input_cross_account_ids"></a> [cross\_account\_ids](#input\_cross\_account\_ids) | The account IDs to allow access to the event bus | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Type of data stored in the resource. Allowed values are: Production, Disaster Recovery, Test QA, Development,Vendor Provided, Scripts | `string` | n/a | yes |
| <a name="input_itcontact"></a> [itcontact](#input\_itcontact) | Email of group responsible for resource | `string` | n/a | yes |
| <a name="input_lambda_target_arns"></a> [lambda\_target\_arns](#input\_lambda\_target\_arns) | The Amazon Resource Name (ARN) of the Lambda Functions you want to use as EventBridge targets | `list(string)` | `[]` | no |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | What is the resource used for | `string` | n/a | yes |
| <a name="input_role_force_detach_policies"></a> [role\_force\_detach\_policies](#input\_role\_force\_detach\_policies) | Specifies to force detaching any policies the IAM role has before destroying it. | `bool` | `true` | no |
| <a name="input_role_permissions_boundary"></a> [role\_permissions\_boundary](#input\_role\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the IAM role used by EventBridge | `string` | `null` | no |
| <a name="input_role_tags"></a> [role\_tags](#input\_role\_tags) | A map of tags to assign to IAM role | `map(string)` | `{}` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | A map of objects with EventBridge Rule definitions. | `map(any)` | `{}` | no |
| <a name="input_schemas_discoverer_description"></a> [schemas\_discoverer\_description](#input\_schemas\_discoverer\_description) | Default schemas discoverer description | `string` | `"Auto schemas discoverer event"` | no |
| <a name="input_sfn_target_arns"></a> [sfn\_target\_arns](#input\_sfn\_target\_arns) | The Amazon Resource Name (ARN) of the StepFunctions you want to use as EventBridge targets | `list(string)` | `[]` | no |
| <a name="input_sqs_target_arns"></a> [sqs\_target\_arns](#input\_sqs\_target\_arns) | The Amazon Resource Name (ARN) of the AWS SQS Queues you want to use as EventBridge targets | `list(string)` | `[]` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | A map of objects with EventBridge Target definitions. | `any` | `{}` | no |
| <a name="input_trusted_entities"></a> [trusted\_entities](#input\_trusted\_entities) | Step Function additional trusted entities for assuming roles (trust relationship) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventbridge_archive_arns"></a> [eventbridge\_archive\_arns](#output\_eventbridge\_archive\_arns) | The EventBridge Archive Arns created |
| <a name="output_eventbridge_bus_arn"></a> [eventbridge\_bus\_arn](#output\_eventbridge\_bus\_arn) | The EventBridge Bus Arn |
| <a name="output_eventbridge_bus_name"></a> [eventbridge\_bus\_name](#output\_eventbridge\_bus\_name) | The EventBridge Bus Name |
| <a name="output_eventbridge_permission_ids"></a> [eventbridge\_permission\_ids](#output\_eventbridge\_permission\_ids) | The EventBridge Permission Arns created |
| <a name="output_eventbridge_role_arn"></a> [eventbridge\_role\_arn](#output\_eventbridge\_role\_arn) | The ARN of the IAM role created for EventBridge |
| <a name="output_eventbridge_rule_arns"></a> [eventbridge\_rule\_arns](#output\_eventbridge\_rule\_arns) | The EventBridge Rule ARNs created |
| <a name="output_eventbridge_rule_ids"></a> [eventbridge\_rule\_ids](#output\_eventbridge\_rule\_ids) | The EventBridge Rule IDs created |
<!-- END_TF_DOCS -->
