# Cloud Storage bucket for user uploads and documents
resource "google_storage_bucket" "main" {
  name     = "${var.storage_bucket_name}-${var.project_id}-${var.environment}"
  location = var.environment == "prod" ? "US" : var.region
  
  # Storage class based on environment
  storage_class = "STANDARD"
  
  # Versioning configuration
  versioning {
    enabled = true
  }
  
  # Lifecycle management
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  
  lifecycle_rule {
    condition {
      age                   = 7
      with_state           = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }
  
  # Auto-class for cost optimization in production
  dynamic "autoclass" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      enabled = true
    }
  }
  
  # Uniform bucket-level access
  uniform_bucket_level_access = true
  
  # CORS configuration for web/mobile access
  cors {
    origin          = var.environment == "prod" ? ["https://viatra.health"] : ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "storage"
  })
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Separate bucket for static assets (if needed)
resource "google_storage_bucket" "assets" {
  name     = "${var.storage_bucket_name}-assets-${var.project_id}-${var.environment}"
  location = var.environment == "prod" ? "US" : var.region
  
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  
  # Public read access for assets
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 86400
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "assets"
  })
}

# IAM binding for Cloud Run service account to access main bucket
resource "google_storage_bucket_iam_binding" "cloud_run_storage_admin" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectAdmin"
  
  members = [
    "serviceAccount:${google_service_account.cloud_run.email}"
  ]
}

# IAM binding for Cloud Run service account to read assets bucket
resource "google_storage_bucket_iam_binding" "cloud_run_assets_viewer" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectViewer"
  
  members = [
    "serviceAccount:${google_service_account.cloud_run.email}"
  ]
}

# Public access for assets bucket (optional, for public assets)
resource "google_storage_bucket_iam_binding" "assets_public_read" {
  count  = var.environment == "prod" ? 0 : 1
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectViewer"
  
  members = [
    "allUsers"
  ]
}
