# VPC Network for private communication
resource "google_compute_network" "main" {
  name                    = "${var.vpc_name}-${var.environment}"
  auto_create_subnetworks = false
  mtu                     = 1460
  
  description = "VPC network for Viatra Health Platform - ${var.environment}"
}

# Subnet for the VPC
resource "google_compute_subnetwork" "main" {
  name          = "${var.subnet_name}-${var.environment}"
  ip_cidr_range = var.environment == "prod" ? "10.0.0.0/24" : "10.1.0.0/24"
  region        = var.region
  network       = google_compute_network.main.id
  
  # Secondary IP ranges for future use (GKE, etc.)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.environment == "prod" ? "10.0.1.0/24" : "10.1.1.0/24"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.environment == "prod" ? "10.0.2.0/24" : "10.1.2.0/24"
  }
  
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# VPC Access Connector for Cloud Run
resource "google_vpc_access_connector" "main" {
  name          = "${var.vpc_connector_name}-${var.environment}"
  region        = var.region
  network       = google_compute_network.main.name
  ip_cidr_range = var.environment == "prod" ? "10.0.3.0/28" : "10.1.3.0/28"
  
  min_throughput = 200
  max_throughput = var.environment == "prod" ? 1000 : 300
}

# Private service access for Cloud SQL and Redis
resource "google_compute_global_address" "private_ip_range" {
  name          = "viatra-private-ip-${var.environment}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
  
  depends_on = [google_project_service.apis]
}

# Cloud Router for Cloud NAT
resource "google_compute_router" "main" {
  name    = "viatra-router-${var.environment}"
  region  = var.region
  network = google_compute_network.main.id
  
  bgp {
    asn = 64514
  }
}

# Cloud NAT for outbound internet access
resource "google_compute_router_nat" "main" {
  name                               = "viatra-nat-${var.environment}"
  router                            = google_compute_router.main.name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "viatra-allow-internal-${var.environment}"
  network = google_compute_network.main.name
  
  description = "Allow internal communication within VPC"
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [
    google_compute_subnetwork.main.ip_cidr_range,
    google_compute_subnetwork.main.secondary_ip_range[0].ip_cidr_range,
    google_compute_subnetwork.main.secondary_ip_range[1].ip_cidr_range
  ]
  
  target_tags = ["viatra-internal"]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "viatra-allow-health-checks-${var.environment}"
  network = google_compute_network.main.name
  
  description = "Allow health checks from Google Cloud Load Balancers"
  
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  
  target_tags = ["viatra-backend"]
}

resource "google_compute_firewall" "deny_all_ingress" {
  name     = "viatra-deny-all-ingress-${var.environment}"
  network  = google_compute_network.main.name
  priority = 65534
  
  description = "Deny all ingress traffic by default"
  
  deny {
    protocol = "all"
  }
  
  source_ranges = ["0.0.0.0/0"]
}

# Optional: Firewall rule for SSH access (development only)
resource "google_compute_firewall" "allow_ssh" {
  count   = var.environment == "dev" ? 1 : 0
  name    = "viatra-allow-ssh-${var.environment}"
  network = google_compute_network.main.name
  
  description = "Allow SSH access for development"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]  # Restrict this in production
  target_tags   = ["viatra-ssh"]
}
