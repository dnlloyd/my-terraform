provider "aws" {
  region = "us-east-1"
}

module "eventbridge" {
  source = "../../"

  bus_name = "my-bus"

  cross_account_ids = ["166865586247", "458891109543"]

  # attach_sfn_policy = true
  # sfn_target_arns   = [module.step_function.state_machine_arn]

  attach_sqs_policy = true
  sqs_target_arns = [aws_sqs_queue.queue.arn]

  attach_cloudwatch_policy = true
  cloudwatch_target_arns   = [aws_cloudwatch_log_group.this.arn]

  rules = {
    orders = {
      description   = "Capture all order data"
      event_pattern = jsonencode({ "source" : ["myapp.orders"] })
      enabled       = false
    }
    # emails = {
    #   description   = "Capture all emails data"
    #   event_pattern = jsonencode({ "source" : ["myapp.emails"] })
    #   enabled       = true
    # }
    # crons = {
    #   description         = "Trigger for a Lambda"
    #   schedule_expression = "rate(5 minutes)"
    # }
  }

  targets = {
    orders = [
      {
        name              = "send-orders-to-sqs"
        arn               = aws_sqs_queue.queue.arn
        # input_transformer = local.order_input_transformer
      },
      {
        name = "log-orders-to-cloudwatch"
        arn  = aws_cloudwatch_log_group.this.arn
      }
    ]

    # emails = [
    #   {
    #     name            = "process-email-with-sfn"
    #     arn             = module.step_function.state_machine_arn
    #     attach_role_arn = true
    #   }
    # ]

    # crons = [
    #   {
    #     name  = "something-for-cron"
    #     arn   = module.lambda.lambda_function_arn
    #     input = jsonencode({ "job" : "crons" })
    #   }
    # ]
  }

  additional_policy_json = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "xray:GetSamplingStatisticSummaries"
        ],
        "Resource": ["*"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "xray:GetSamplingRules"
        ],
        "Resource": ["*"]
      },
      {
        "Effect": "Allow",
        "Action": [
          "xray:ListResourcePolicies"
        ],
        "Resource": ["*"]
      }
    ]
  })

  additional_policies = ["arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"]

  purpose             = "test"
  itcontact           = "test"
  costcenter          = "1234567"
  businessline        = "test"
  environment         = "Development"
}

# locals {
#   order_input_transformer = {
#     input_paths = {
#       order_id = "$.detail.order_id"
#     }
#     input_template = <<EOF
#     {
#       "id": <order_id>
#     }
#     EOF
#   }
# }

# Mock resources
resource "random_pet" "this" {
  length = 2
}

resource "aws_sqs_queue" "queue" {
  name = "${random_pet.this.id}-queue"
}

resource "aws_sqs_queue_policy" "queue" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.queue.json
}

data "aws_iam_policy_document" "queue" {
  statement {
    sid     = "events-policy"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sqs_queue.queue.arn
    ]
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/events/${random_pet.this.id}"

  tags = {
    Name = "${random_pet.this.id}-log-group"
  }
}
