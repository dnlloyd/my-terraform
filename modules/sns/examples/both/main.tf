provider "aws" {
  region = "us-east-1"
}

module "sns_topic_and_sub" {
  source = "../../"
  name = "my-topic"
  create_sns_topic = true
  subscription_accounts = "458891109543"
  create_sns_subscription = true
  subscription_type = "email"
  subscription_endpoint = "dnlloyd@gmail.com"
}
