variable "project_id" {
  description = "The GCP project ID"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_id))
    error_message = "Project ID must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
  validation {
    condition = contains([
      "us-central1",
      "us-east1",
      "us-west1",
      "europe-west1",
      "asia-northeast1"
    ], var.region)
    error_message = "Region must be a valid GCP region."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "db_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
  default     = "viatra-db"
}

variable "db_tier" {
  description = "The machine type for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
  validation {
    condition = contains([
      "db-f1-micro",
      "db-g1-small",
      "db-n1-standard-1",
      "db-n1-standard-2",
      "db-n1-standard-4"
    ], var.db_tier)
    error_message = "Database tier must be a valid Cloud SQL machine type."
  }
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
  validation {
    condition     = var.redis_memory_size_gb >= 1 && var.redis_memory_size_gb <= 300
    error_message = "Redis memory size must be between 1 and 300 GB."
  }
}

variable "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket"
  type        = string
  default     = "viatra-storage"
}

variable "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "viatra-backend"
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "viatra-vpc"
}

variable "subnet_name" {
  description = "Name of the VPC subnet"
  type        = string
  default     = "viatra-subnet"
}

variable "vpc_connector_name" {
  description = "Name of the VPC connector for Cloud Run"
  type        = string
  default     = "viatra-connector"
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run service"
  type        = string
  default     = "1000m"
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run service"
  type        = string
  default     = "512Mi"
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    project     = "viatra-health"
    managed-by  = "terraform"
  }
}

variable "github_owner" {
  description = "GitHub repository owner/organization name"
  type        = string
  validation {
    condition     = length(var.github_owner) > 0 && can(regex("^[a-zA-Z0-9._-]+$", var.github_owner))
    error_message = "GitHub owner is required and must contain only alphanumeric characters, dots, hyphens, and underscores."
  }
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "VIATRA"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]*$", var.github_repo))
    error_message = "GitHub repository name must contain only alphanumeric characters, dots, hyphens, and underscores."
  }
}

variable "region_suffix" {
  description = "Short region suffix for resource naming"
  type        = string
  default     = "uc"
  validation {
    condition     = length(var.region_suffix) <= 3
    error_message = "Region suffix must be 3 characters or less."
  }
}

variable "enable_cloudbuild_triggers" {
  description = "Whether Cloud Build triggers should be managed by Terraform. Set to false if managing triggers manually in GCP Console."
  type        = bool
  default     = true
}
