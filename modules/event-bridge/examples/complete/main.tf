provider "aws" {
  region = "us-east-1"
}

locals {
  # List of account IDs that need access to EventBridge bus
  accounts = ["458891109543"]
}

module "eventbridge" {
  source = "../../"

  bus_name = "my-bus"

  # Allow cross account access
  create_event_bus_policy = true
  event_bus_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [    
      {
    
        "Sid": "allow_account_to_put_events",
        "Effect": "Allow",
        "Principal": {
          "AWS": local.accounts
        },
        "Action": "events:PutEvents",
        "Resource": "${module.eventbridge.eventbridge_bus_arn}"
      }
    ]
  })

  sqs_target_arns   = [aws_sqs_queue.queue.arn]
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
