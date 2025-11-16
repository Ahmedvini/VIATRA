# Generate random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "main" {
  name             = "${var.db_instance_name}-${var.environment}"
  database_version = "POSTGRES_15"
  region          = var.region
  
  settings {
    tier              = var.db_tier
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = var.environment == "prod" ? 100 : 20
    disk_autoresize   = true
    
    backup_configuration {
      enabled                        = true
      start_time                    = "02:00"
      point_in_time_recovery_enabled = var.environment == "prod"
      transaction_log_retention_days = var.environment == "prod" ? 7 : 1
      
      backup_retention_settings {
        retained_backups = var.environment == "prod" ? 30 : 7
        retention_unit   = "COUNT"
      }
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      require_ssl     = true
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
    
    database_flags {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    }
    
    maintenance_window {
      day  = 7
      hour = 3
    }
    
    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }
  }
  
  deletion_protection = var.environment == "prod"
  
  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "database"
  })
}

# Main application database
resource "google_sql_database" "main" {
  name     = "viatra"
  instance = google_sql_database_instance.main.name
  
  depends_on = [google_sql_database_instance.main]
}

# Database user
resource "google_sql_user" "main" {
  name     = "viatra_app"
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
  
  depends_on = [google_sql_database_instance.main]
}

# Store database password in Secret Manager
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = merge(var.labels, {
    environment = var.environment
    service     = "database"
  })
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}
