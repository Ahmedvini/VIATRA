output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}

# Database outputs
output "db_instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "db_instance_ip_address" {
  description = "Cloud SQL instance private IP address"
  value       = google_sql_database_instance.main.private_ip_address
}

output "database_name" {
  description = "Name of the main database"
  value       = google_sql_database.main.name
}

output "db_password_secret_id" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}

# Redis outputs
output "redis_host" {
  description = "Redis instance host"
  value       = google_redis_instance.main.host
}

output "redis_port" {
  description = "Redis instance port"
  value       = google_redis_instance.main.port
}

output "redis_auth_string_secret_id" {
  description = "Secret Manager secret ID for Redis auth string"
  value       = google_secret_manager_secret.redis_auth.secret_id
}

# Storage outputs
output "storage_bucket_name" {
  description = "Cloud Storage bucket name"
  value       = google_storage_bucket.main.name
}

output "storage_bucket_url" {
  description = "Cloud Storage bucket URL"
  value       = google_storage_bucket.main.url
}

# Cloud Run outputs
output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.backend.status[0].url
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_service.backend.name
}

# VPC outputs
output "vpc_network_name" {
  description = "VPC network name"
  value       = google_compute_network.main.name
}

output "vpc_subnet_name" {
  description = "VPC subnet name"
  value       = google_compute_subnetwork.main.name
}

output "vpc_connector_name" {
  description = "VPC connector name"
  value       = google_vpc_access_connector.main.name
}

# Service account outputs
output "cloud_run_service_account_email" {
  description = "Cloud Run service account email"
  value       = google_service_account.cloud_run.email
}

output "cloud_build_service_account_email" {
  description = "Cloud Build service account email"
  value       = google_service_account.cloud_build.email
}

# Secret Manager outputs
output "jwt_secret_id" {
  description = "Secret Manager secret ID for JWT secret"
  value       = google_secret_manager_secret.jwt_secret.secret_id
}

output "api_keys_secret_id" {
  description = "Secret Manager secret ID for API keys"
  value       = google_secret_manager_secret.api_keys.secret_id
}

# Container Registry outputs
output "container_registry_hostname" {
  description = "Container Registry hostname"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/viatra-repo"
}
