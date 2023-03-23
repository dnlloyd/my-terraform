# AWS EventBridge Terraform module

Terraform module to create EventBridge resources

## Production Versions History

|Version  |Release Notes  |
|---------|---------|
|0.0.1    |Initial release |
|1.0.0    |Extend module to most EventBridge resources |


## Example module instantiation

```hcl
module "eventbridge" {
  source = "../../"

  bus_name = "my-bus"

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
        arn  = aws_cloudwatch_log_group.cloudwatch_log_group.arn
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

## Cross account access

Cross account access is granted via a resource-based policy attached directly to the bus. This policy cannot be defined by an existing policy or role. To create a policy, pass in JSON to the `event_bus_policy` variable.

```
  create_event_bus_policy = true
  event_bus_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {

        "Sid": "allow_account_to_put_events",
        "Effect": "Allow",
        "Principal": {
          "AWS": "123456789012"
        },
        "Action": "events:PutEvents",
        "Resource": "${module.eventbridge.eventbridge_bus_arn}"
      }
    ]
  })
```

### Testing cross account access to bus

(From an external AWS account)

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

## Access to EventBridge targets

EventBridge targets typically require IAM roles that grant permission to EventBridge to invoke the target.

[https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-identity-based.html#eb-target-permissions](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-identity-based.html#eb-target-permissions)

### Example for AWS step function target

If the target is an AWS Step Functions state machine, the role that you specify must include the following policy.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
             "Action": [ "states:StartExecution" ],
            "Resource": [ "<Step Function Target ARN>" ]
        }
     ]
}
```

Note: The role must have a trust relationship allowing the EventBridge service to assume the role

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

Associate the role with the event rule target by defining it inside the module as below

```
  targets = {
    orders = [
      {
        name = "process-email-with-sfn"
        arn  = aws_sfn_state_machine.sfn.arn
        role_arn = "<Add role ARN here>"
      }
    ]
  }
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
| [aws_cloudwatch_event_archive.cloudwatch_event_archive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_archive) | resource |
| [aws_cloudwatch_event_bus.event_bus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_bus_policy.cloudwatch_event_bus_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy) | resource |
| [aws_cloudwatch_event_rule.cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_schemas_discoverer.schemas_discoverer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/schemas_discoverer) | resource |
| [aws_cloudwatch_event_bus.event_bus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_event_bus) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | A map of additional tags. Required tags are set as mandatory variables | `map(any)` | `{}` | no |
| <a name="input_archives"></a> [archives](#input\_archives) | A map of objects with the EventBridge Archive definitions. | `map(any)` | `{}` | no |
| <a name="input_bus_name"></a> [bus\_name](#input\_bus\_name) | A unique name for your EventBridge Bus | `string` | `"default"` | no |
| <a name="input_businessline"></a> [businessline](#input\_businessline) | Business Line responsible for resource ownership | `string` | n/a | yes |
| <a name="input_cloudwatch_target_arns"></a> [cloudwatch\_target\_arns](#input\_cloudwatch\_target\_arns) | The Amazon Resource Name (ARN) of the Cloudwatch Log Streams you want to use as EventBridge targets | `list(string)` | `[]` | no |
| <a name="input_costcenter"></a> [costcenter](#input\_costcenter) | Seven digits number of the Cost Center for resource ownership | `string` | n/a | yes |
| <a name="input_create_archives"></a> [create\_archives](#input\_create\_archives) | Controls whether EventBridge Archive resources should be created | `bool` | `false` | no |
| <a name="input_create_bus"></a> [create\_bus](#input\_create\_bus) | Controls whether EventBridge Bus resource should be created | `bool` | `true` | no |
| <a name="input_create_event_bus_policy"></a> [create\_event\_bus\_policy](#input\_create\_event\_bus\_policy) | Controls whether EventBridge bus policy should be created | `bool` | `false` | no |
| <a name="input_create_rules"></a> [create\_rules](#input\_create\_rules) | Controls whether EventBridge Rule resources should be created | `bool` | `true` | no |
| <a name="input_create_schemas_discoverer"></a> [create\_schemas\_discoverer](#input\_create\_schemas\_discoverer) | Controls whether default schemas discoverer should be created | `bool` | `false` | no |
| <a name="input_create_targets"></a> [create\_targets](#input\_create\_targets) | Controls whether EventBridge Target resources should be created | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Type of data stored in the resource. Allowed values are: Production, Disaster Recovery, Test QA, Development,Vendor Provided, Scripts | `string` | n/a | yes |
| <a name="input_event_bus_policy"></a> [event\_bus\_policy](#input\_event\_bus\_policy) | IAM policy to support cross-account events | `string` | `null` | no |
| <a name="input_itcontact"></a> [itcontact](#input\_itcontact) | Email of group responsible for resource | `string` | n/a | yes |
| <a name="input_lambda_target_arns"></a> [lambda\_target\_arns](#input\_lambda\_target\_arns) | The Amazon Resource Name (ARN) of the Lambda Functions you want to use as EventBridge targets | `list(string)` | `[]` | no |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | What is the resource used for | `string` | n/a | yes |
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
| <a name="output_eventbridge_rule_arns"></a> [eventbridge\_rule\_arns](#output\_eventbridge\_rule\_arns) | The EventBridge Rule ARNs created |
| <a name="output_eventbridge_rule_ids"></a> [eventbridge\_rule\_ids](#output\_eventbridge\_rule\_ids) | The EventBridge Rule IDs created |
<!-- END_TF_DOCS -->
