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

variable "create_role" {
  description = "Controls whether IAM roles should be created"
  type        = bool
  default     = true
}

variable "role_force_detach_policies" {
  description = "Specifies to force detaching any policies the IAM role has before destroying it."
  type        = bool
  default     = true
}

variable "role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role used by EventBridge"
  type        = string
  default     = null
}

variable "role_tags" {
  description = "A map of tags to assign to IAM role"
  type        = map(string)
  default     = {}
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

# Cross account access
variable "cross_account_ids" {
  description = "The account IDs to allow access to the event bus"
  type        = list(string)
  default     = []
}

# Canned policies
variable "attach_sqs_policy" {
  description = "Controls whether the SQS policy should be added to IAM role for EventBridge Target"
  type        = bool
  default     = false
}

variable "attach_lambda_policy" {
  description = "Controls whether the Lambda Function policy should be added to IAM role for EventBridge Target"
  type        = bool
  default     = false
}

variable "attach_sfn_policy" {
  description = "Controls whether the StepFunction policy should be added to IAM role for EventBridge Target"
  type        = bool
  default     = false
}

variable "attach_cloudwatch_policy" {
  description = "Controls whether the Cloudwatch policy should be added to IAM role for EventBridge Target"
  type        = bool
  default     = false
}

variable "attach_tracing_policy" {
  description = "Controls whether X-Ray tracing policy should be added to IAM role for EventBridge"
  type        = bool
  default     = false
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

# Additional policies
variable "additional_policy_json" {
  description = "An additional policy document as JSON to attach to IAM role"
  type        = string
  default     = null
}

variable "additional_policies" {
  description = "List of policy statements ARN to attach to IAM role"
  type        = list(string)
  default     = null
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
