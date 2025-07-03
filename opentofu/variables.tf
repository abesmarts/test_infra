variable "network_cidr" {
  description = "CIDR block for the main VM network"
  type        = string
  default     = "198.51.100.0/24"
}

variable "gateway_ip" {
  description = "Gateway IP address for the VM network"
  type        = string
  default     = "198.51.100.1"
}

variable "semaphore_api_token" {
  description = "API token for Semaphore UI backend"
  type        = string
  sensitive   = true
}

variable "semaphore_project_id" {
  description = "Semaphore project ID for state management"
  type        = string
  default     = "1"
}

variable "deployment_environment" {
  description = "Environment managed by Semaphore"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.deployment_environment)
    error_message = "Environment must be development, staging, or production."
  }
}