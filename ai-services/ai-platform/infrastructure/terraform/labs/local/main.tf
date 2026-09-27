terraform {
  required_version = ">= 1.11.0, < 2.0.0"
}

variable "environment" {
  type        = string
  default     = "local"
  description = "Educational state only; no cloud provider is used."
  validation {
    condition     = contains(["local", "dev", "staging", "prod"], var.environment)
    error_message = "Use local, dev, staging or prod."
  }
}

resource "terraform_data" "platform_contract" {
  input = {
    environment = var.environment
    namespace   = "orzyon"
    owner       = "platform"
  }
}

output "platform_contract" {
  value = terraform_data.platform_contract.output
}
