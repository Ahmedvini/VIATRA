# Service account for Cloud Run backend service
resource "google_service_account" "cloud_run" {
  account_id   = "viatra-cloud-run-${var.environment}"
  display_name = "Viatra Cloud Run Service Account - ${title(var.environment)}"
  description  = "Service account for Viatra Cloud Run backend service in ${var.environment}"
}

# Service account for Cloud Build CI/CD
resource "google_service_account" "cloud_build" {
  account_id   = "viatra-cloud-build-${var.environment}"
  display_name = "Viatra Cloud Build Service Account - ${title(var.environment)}"
  description  = "Service account for Viatra Cloud Build CI/CD pipeline in ${var.environment}"
}

# IAM roles for Cloud Run service account
resource "google_project_iam_member" "cloud_run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_trace_agent" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# IAM roles for Cloud Build service account
resource "google_project_iam_member" "cloud_build_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_secret_admin" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_artifact_registry_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_source_repo_admin" {
  project = var.project_id
  role    = "roles/source.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

# Custom IAM role for Cloud Run deployment (more restrictive than run.admin)
resource "google_project_iam_custom_role" "cloud_run_deployer" {
  role_id     = "viatraCloudRunDeployer${title(var.environment)}"
  title       = "Viatra Cloud Run Deployer - ${title(var.environment)}"
  description = "Custom role for deploying Cloud Run services for Viatra in ${var.environment}"
  
  permissions = [
    "run.services.create",
    "run.services.delete",
    "run.services.get",
    "run.services.list",
    "run.services.update",
    "run.revisions.create",
    "run.revisions.delete",
    "run.revisions.get",
    "run.revisions.list",
    "run.configurations.get",
    "run.configurations.list",
    "run.routes.get",
    "run.routes.list"
  ]
}

# Grant custom role to Cloud Build service account
resource "google_project_iam_member" "cloud_build_custom_deployer" {
  project = var.project_id
  role    = google_project_iam_custom_role.cloud_run_deployer.name
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

# IAM binding for Secret Manager secrets access
resource "google_secret_manager_secret_iam_binding" "cloud_run_db_password_access" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  
  members = [
    "serviceAccount:${google_service_account.cloud_run.email}"
  ]
}

resource "google_secret_manager_secret_iam_binding" "cloud_run_redis_auth_access" {
  secret_id = google_secret_manager_secret.redis_auth.secret_id
  role      = "roles/secretmanager.secretAccessor"
  
  members = [
    "serviceAccount:${google_service_account.cloud_run.email}"
  ]
}

resource "google_secret_manager_secret_iam_binding" "cloud_run_jwt_secret_access" {
  secret_id = google_secret_manager_secret.jwt_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  
  members = [
    "serviceAccount:${google_service_account.cloud_run.email}"
  ]
}

resource "google_secret_manager_secret_iam_binding" "cloud_run_api_keys_access" {
  secret_id = google_secret_manager_secret.api_keys.secret_id
  role      = "roles/secretmanager.secretAccessor"
  
  members = [
    "serviceAccount:${google_service_account.cloud_run.email}"
  ]
}
