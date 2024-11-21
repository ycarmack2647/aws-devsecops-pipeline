variable "resource_prefix" {
  type        = string
  description = "Prefix for AWS Resources"
  default     = "dsb"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "SNYK_TOKEN" {}
variable "SNYK_ORG_ID" {}