# Generate JWT secret
resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

# JWT secret for authentication
resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "jwt-secret-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "auth"
  })
}

resource "google_secret_manager_secret_version" "jwt_secret" {
  secret      = google_secret_manager_secret.jwt_secret.id
  secret_data = random_password.jwt_secret.result
}

# API keys and third-party service credentials
resource "google_secret_manager_secret" "api_keys" {
  secret_id = "api-keys-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "external"
  })
}

# Placeholder for API keys - will be updated manually or via CI/CD
resource "google_secret_manager_secret_version" "api_keys" {
  secret = google_secret_manager_secret.api_keys.id
  secret_data = jsonencode({
    stripe_api_key     = "placeholder_stripe_key"
    twilio_auth_token  = "placeholder_twilio_token"
    sendgrid_api_key   = "placeholder_sendgrid_key"
    firebase_key       = "placeholder_firebase_key"
  })
}

# Application configuration secrets
resource "google_secret_manager_secret" "app_config" {
  secret_id = "app-config-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "config"
  })
}

resource "google_secret_manager_secret_version" "app_config" {
  secret = google_secret_manager_secret.app_config.id
  secret_data = jsonencode({
    encryption_key        = base64encode(random_password.jwt_secret.result)
    session_secret       = random_password.jwt_secret.result
    password_pepper      = substr(random_password.jwt_secret.result, 0, 32)
    file_upload_max_size = "10485760"  # 10MB
    rate_limit_max       = "100"
    rate_limit_window    = "900000"    # 15 minutes
  })
}

# SSL/TLS certificates (if using custom domain)
resource "google_secret_manager_secret" "ssl_certificates" {
  count     = var.environment == "prod" ? 1 : 0
  secret_id = "ssl-certificates-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "ssl"
  })
}

# Placeholder for SSL certificates
resource "google_secret_manager_secret_version" "ssl_certificates" {
  count  = var.environment == "prod" ? 1 : 0
  secret = google_secret_manager_secret.ssl_certificates[0].id
  secret_data = jsonencode({
    private_key  = "placeholder_private_key"
    certificate  = "placeholder_certificate"
    ca_bundle    = "placeholder_ca_bundle"
  })
}

# OAuth configuration for social login
resource "google_secret_manager_secret" "oauth_config" {
  secret_id = "oauth-config-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "oauth"
  })
}

resource "google_secret_manager_secret_version" "oauth_config" {
  secret = google_secret_manager_secret.oauth_config.id
  secret_data = jsonencode({
    google_client_id     = "placeholder_google_client_id"
    google_client_secret = "placeholder_google_client_secret"
    apple_client_id      = "placeholder_apple_client_id"
    apple_client_secret  = "placeholder_apple_client_secret"
    facebook_app_id      = "placeholder_facebook_app_id"
    facebook_app_secret  = "placeholder_facebook_app_secret"
  })
}

# Database connection string (composite secret)
resource "google_secret_manager_secret" "database_url" {
  secret_id = "database-url-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "database"
  })
}

resource "google_secret_manager_secret_version" "database_url" {
  secret = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${google_sql_user.main.name}:${random_password.db_password.result}@${google_sql_database_instance.main.private_ip_address}:5432/${google_sql_database.main.name}?sslmode=require"
  
  depends_on = [
    google_sql_database_instance.main,
    google_sql_database.main,
    google_sql_user.main
  ]
}

# Redis connection configuration
resource "google_secret_manager_secret" "redis_config" {
  secret_id = "redis-config-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "cache"
  })
}

resource "google_secret_manager_secret_version" "redis_config" {
  secret = google_secret_manager_secret.redis_config.id
  secret_data = jsonencode({
    host     = google_redis_instance.main.host
    port     = google_redis_instance.main.port
    auth     = random_password.redis_auth.result
    database = 0
    ssl      = var.environment == "prod"
  })
  
  depends_on = [google_redis_instance.main]
}
