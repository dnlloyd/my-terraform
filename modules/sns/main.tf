resource "aws_sns_topic" "this" {
  count = var.create_sns_topic == true ? 1 : 0 
  name = var.name
}

resource "aws_sns_topic_policy" "default" {
  count = var.create_sns_topic == true ? 1 : 0 
  arn = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = var.create_sns_topic == true ? 1 : 0 
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SNS:Subscribe"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.create_sns_topic == true ? var.subscription_accounts : ""}:root"]
    }
    resources = [
      aws_sns_topic.this[0].arn,
    ]
  }
}

resource "aws_sns_topic_subscription" "this" {
  count = var.create_sns_subscription == true ? 1 : 0 
  topic_arn = var.create_sns_topic == true ? aws_sns_topic.this[0].arn : var.topic_arn
  protocol  = var.subscription_type
  endpoint  = var.subscription_endpoint
}
