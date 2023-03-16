variable "create_bus" {
  description = "Controls whether EventBridge Bus resource should be created"
  type        = bool
  default     = true
}

variable "bus_name" {
  description = "A unique name for your EventBridge Bus"
  type        = string
  default     = "default"
}

variable "create_rules" {
  description = "Controls whether EventBridge Rule resources should be created"
  type        = bool
  default     = true
}

variable "rules" {
  description = "A map of objects with EventBridge Rule definitions."
  type        = map(any)
  default     = {}
}

variable "create_targets" {
  description = "Controls whether EventBridge Target resources should be created"
  type        = bool
  default     = true
}

variable "targets" {
  description = "A map of objects with EventBridge Target definitions."
  type        = any
  default     = {}
}


variable "create_archives" {
  description = "Controls whether EventBridge Archive resources should be created"
  type        = bool
  default     = false
}

variable "archives" {
  description = "A map of objects with the EventBridge Archive definitions."
  type        = map(any)
  default     = {}
}

variable "create_schemas_discoverer" {
  description = "Controls whether default schemas discoverer should be created"
  type        = bool
  default     = false
}

variable "schemas_discoverer_description" {
  description = "Default schemas discoverer description"
  type        = string
  default     = "Auto schemas discoverer event"
}

variable "create_event_bus_policy" {
  description = "Controls whether EventBridge bus policy should be created"
  type        = bool
  default     = false
}

variable "event_bus_policy" {
  description = "IAM policy to support cross-account events"
  type        = string
  default     = null
}

variable "sqs_target_arns" {
  description = "The Amazon Resource Name (ARN) of the AWS SQS Queues you want to use as EventBridge targets"
  type        = list(string)
  default     = []
}

variable "lambda_target_arns" {
  description = "The Amazon Resource Name (ARN) of the Lambda Functions you want to use as EventBridge targets"
  type        = list(string)
  default     = []
}

variable "sfn_target_arns" {
  description = "The Amazon Resource Name (ARN) of the StepFunctions you want to use as EventBridge targets"
  type        = list(string)
  default     = []
}

variable "cloudwatch_target_arns" {
  description = "The Amazon Resource Name (ARN) of the Cloudwatch Log Streams you want to use as EventBridge targets"
  type        = list(string)
  default     = []
}

variable "trusted_entities" {
  description = "Step Function additional trusted entities for assuming roles (trust relationship)"
  type        = list(string)
  default     = []
}

variable "purpose" {
  type        = string
  description = "What is the resource used for"
}

variable "itcontact" {
  type        = string
  description = "Email of group responsible for resource"
}

variable "costcenter" {
  type        = string
  description = "Seven digits number of the Cost Center for resource ownership"
  validation {
    condition     = length(var.costcenter) == 7
    error_message = "Valid values for variable removeondate must be a seven digits number."
  }
}

variable "businessline" {
  type        = string
  description = "Business Line responsible for resource ownership"
}

variable "environment" {
  type        = string
  description = "Type of data stored in the resource. Allowed values are: Production, Disaster Recovery, Test QA, Development,Vendor Provided, Scripts"
  validation {
    condition     = contains(["Production", "Disaster Recovery", "Test QA", "Development", "Vendor Provided", "Scripts"], var.environment)
    error_message = "Valid values for variable environment: Production, Disaster Recovery, Test QA, Development,Vendor Provided, Scripts."
  }
}

variable "additional_tags" {
  description = "A map of additional tags. Required tags are set as mandatory variables"
  type        = map(any)
  default     = {}
}

locals {
  tags = {
    Purpose            = var.purpose,
    ITContact          = var.itcontact,
    CostCenter         = var.costcenter,
    BusinessLine       = var.businessline,
    Environment        = var.environment,
    ManagedByTerraform = true
  }
}
