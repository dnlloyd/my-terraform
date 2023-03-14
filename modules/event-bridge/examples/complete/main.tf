provider "aws" {
  region = "us-east-1"
}

module "eventbridge" {
  source = "../../"

  bus_name = "my-bus"

  cross_account_ids = ["123456789012", "210987654321"]

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
  }

  targets = {
    orders = [
      {
        name = "send-orders-to-sqs"
        arn  = aws_sqs_queue.queue.arn
      },
      {
        name = "log-orders-to-cloudwatch"
        arn  = aws_cloudwatch_log_group.this.arn
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
