# Artifact Registry repository for container images
resource "google_artifact_registry_repository" "viatra_repo" {
  location      = var.region
  repository_id = "viatra-repo"
  description   = "Viatra Health Platform container images"
  format        = "DOCKER"
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "registry"
  })
}

# Cloud Run service for the backend API
resource "google_cloud_run_service" "backend" {
  name     = "${var.cloud_run_service_name}-${var.environment}"
  location = var.region
  
  template {
    metadata {
      labels = merge(var.labels, {
        environment = var.environment
        service     = "backend"
      })
      
      annotations = {
        "autoscaling.knative.dev/maxScale"      = tostring(var.cloud_run_max_instances)
        "autoscaling.knative.dev/minScale"      = tostring(var.cloud_run_min_instances)
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
    
    spec {
      service_account_name = google_service_account.cloud_run.email
      
      containers {
        # Placeholder image - will be updated by CI/CD pipeline
        # The actual backend image is deployed via Cloud Build to prevent Terraform drift
        image = "gcr.io/cloudrun/hello"
        
        ports {
          container_port = 8080
        }
        
        resources {
          limits = {
            cpu    = var.cloud_run_cpu
            memory = var.cloud_run_memory
          }
        }
        
        env {
          name  = "NODE_ENV"
          value = var.environment == "prod" ? "production" : "development"
        }
        
        env {
          name  = "PORT"
          value = "8080"
        }
        
        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        
        # Database configuration from Secret Manager
        # Preferred: Composite DATABASE_URL (complete connection string)
        # This provides a cleaner, single-source configuration approach
        env {
          name = "DATABASE_URL"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.database_url.secret_id
              key  = "latest"
            }
          }
        }
        
        # Backwards compatibility: Discrete database configuration
        # These are maintained for legacy compatibility but DATABASE_URL takes precedence
        env {
          name = "DATABASE_HOST"
          value = google_sql_database_instance.main.private_ip_address
        }
        
        env {
          name = "DATABASE_NAME"
          value = google_sql_database.main.name
        }
        
        env {
          name = "DATABASE_USER"
          value = google_sql_user.main.name
        }
        
        env {
          name = "DATABASE_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_password.secret_id
              key  = "latest"
            }
          }
        }
        
        # Redis configuration
        env {
          name = "REDIS_HOST"
          value = google_redis_instance.main.host
        }
        
        env {
          name = "REDIS_PORT"
          value = tostring(google_redis_instance.main.port)
        }
        
        env {
          name = "REDIS_AUTH"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.redis_auth.secret_id
              key  = "latest"
            }
          }
        }
        
        # Storage configuration
        env {
          name = "GCS_BUCKET_NAME"
          value = google_storage_bucket.main.name
        }
        
        # JWT secret from Secret Manager
        env {
          name = "JWT_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.jwt_secret.secret_id
              key  = "latest"
            }
          }
        }
        
        # Liveness and readiness probes
        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 30
          timeout_seconds       = 5
          period_seconds        = 10
          failure_threshold     = 3
        }
        
        startup_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 10
          timeout_seconds       = 5
          period_seconds        = 10
          failure_threshold     = 10
        }
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  # Prevent Terraform drift when CI/CD updates the container image
  # This allows CI/CD to manage the runtime image while Terraform manages the infrastructure
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,                                    # CI/CD deploys backend images
      template[0].metadata[0].annotations["run.googleapis.com/execution-environment"], # May be set dynamically
      traffic[0].latest_revision                                                  # CI/CD manages traffic routing
    ]
  }
  
  autogenerate_revision_name = true
  
  depends_on = [
    google_project_service.apis
  ]
}

# IAM policy to allow unauthenticated access (will be secured at application level)
resource "google_cloud_run_service_iam_binding" "public_access" {
  count    = var.environment == "dev" ? 1 : 0
  location = google_cloud_run_service.backend.location
  service  = google_cloud_run_service.backend.name
  role     = "roles/run.invoker"
  
  members = [
    "allUsers"
  ]
}

# IAM policy for authenticated access in staging/prod
resource "google_cloud_run_service_iam_binding" "authenticated_access" {
  count    = var.environment != "dev" ? 1 : 0
  location = google_cloud_run_service.backend.location
  service  = google_cloud_run_service.backend.name
  role     = "roles/run.invoker"
  
  members = [
    "serviceAccount:${google_service_account.cloud_run.email}",
    # Add specific users or service accounts as needed
  ]
}
