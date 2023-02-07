variable "name" {
  description = "The name of the SNS topic to create"
  type        = string
  default     = null
}

variable subscription_accounts {
  description = "The account IDs to give access to publish to the topic"
  type = string
  default = null
}

variable "create_sns_topic" {
  type = bool
  default = true
}

variable "create_sns_subscription" {
  type = bool
  default = false
}

variable "subscription_type" {
  type = string
  default = ""
  description = "Must be either email or sqs"
}

variable "subscription_endpoint" {
  type = string
  default = null
}

variable "topic_arn" {
  type = string
  default = null
}
