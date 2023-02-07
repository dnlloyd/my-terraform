provider "aws" {
  region = "us-east-1"
}

module "sns_topic" {
  source = "../../"
  name = "MyTopic"
  subscription_accounts = "458891109543"
}

module "sns_topic_subscription" {
  source = "../../"
  name = "test-topic"
  create_sns_topic = false
  create_sns_subscription = true
  topic_arn = module.sns_topic.topic_arn
  subscription_type = "email"
  subscription_endpoint = "dnlloyd@gmail.com"
}
