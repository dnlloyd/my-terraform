provider "aws" {
  region = "us-east-1"
}

module "sns_topic" {
  source = "../../"
  name = "MyTopic"
  subscription_accounts = "458891109543"
}
