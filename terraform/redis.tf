# Generate Redis auth string
resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

# Redis Memorystore instance
resource "google_redis_instance" "main" {
  name               = "viatra-redis-${var.environment}"
  memory_size_gb     = var.redis_memory_size_gb
  region             = var.region
  
  # Use STANDARD_HA for production, BASIC for dev/staging
  tier = var.environment == "prod" ? "STANDARD_HA" : "BASIC"
  
  redis_version     = "REDIS_7_0"
  display_name      = "Viatra Redis Cache - ${title(var.environment)}"
  
  # Network configuration
  authorized_network = google_compute_network.main.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  
  # Security configuration
  auth_enabled       = true
  auth_string        = random_password.redis_auth.result
  transit_encryption_mode = var.environment == "prod" ? "SERVER_AUTHENTICATION" : "DISABLED"
  
  # Redis configuration
  redis_configs = {
    maxmemory-policy = "allkeys-lru"
    notify-keyspace-events = "Ex"
  }
  
  # Maintenance window
  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 3
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "cache"
  })
  
  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

# Store Redis auth string in Secret Manager
resource "google_secret_manager_secret" "redis_auth" {
  secret_id = "redis-auth-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "cache"
  })
}

resource "google_secret_manager_secret_version" "redis_auth" {
  secret      = google_secret_manager_secret.redis_auth.id
  secret_data = random_password.redis_auth.result
}
