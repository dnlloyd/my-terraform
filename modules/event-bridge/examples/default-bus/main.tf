provider "aws" {
  region = "us-east-1"
}

module "eventbridge" {
  source = "../../"

  create_bus = false

  rules = {
    product_create = {
      description   = "Mock rule",
      event_pattern = jsonencode({ "source" : ["my.test"] })
    }
  }

  targets = {
    product_create = [
      {
        arn  = aws_sqs_queue.mock.arn
        name = "send-test-to-sqs"
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

resource "aws_sqs_queue" "mock" {
  name = random_pet.this.id
}
