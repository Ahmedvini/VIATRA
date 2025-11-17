# Cloud Build Triggers Configuration
# 
# This file defines the Cloud Build triggers for automated CI/CD pipelines
# These triggers are referenced by outputs in outputs.tf

# Cloud Build trigger for main branch deployments
resource "google_cloudbuild_trigger" "main_branch" {
  count       = var.enable_cloudbuild_triggers ? 1 : 0
  project     = var.project_id
  name        = "viatra-backend-main-${var.environment}"
  description = "Automated deployment on main branch push for ${var.environment} environment"
  location    = var.region

  # GitHub repository configuration
  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }

  # Build configuration file
  filename = "cloudbuild.yaml"

  # Use dedicated Cloud Build service account
  service_account = google_service_account.cloud_build.id

  # Environment-specific substitutions
  substitutions = {
    _ENVIRONMENT           = var.environment
    _REGION               = var.region
    _SERVICE_ACCOUNT_EMAIL = google_service_account.cloud_build.email
    _CLOUD_RUN_SERVICE_ACCOUNT = google_service_account.cloud_run.email
  }

  # Approval required for production deployments
  approval_config {
    approval_required = var.environment == "prod"
  }

  # Dependencies to ensure proper resource creation order
  depends_on = [
    google_service_account.cloud_build,
    google_project_iam_member.cloud_build_run_admin,
    google_artifact_registry_repository.viatra_repo
  ]

  # Labels for resource organization
  labels = merge(var.labels, {
    environment = var.environment
    service     = "cicd"
    trigger     = "main-branch"
  })
}

# Cloud Build trigger for pull request validation
resource "google_cloudbuild_trigger" "pull_request" {
  count       = var.enable_cloudbuild_triggers ? 1 : 0
  project     = var.project_id
  name        = "viatra-backend-pr-${var.environment}"
  description = "Pull request validation builds for ${var.environment} environment"
  location    = var.region

  # GitHub repository configuration
  github {
    owner = var.github_owner
    name  = var.github_repo
    pull_request {
      branch = "^main$"
    }
  }

  # Use dedicated Cloud Build service account
  service_account = google_service_account.cloud_build.id

  # Inline build configuration for PR validation (no deployment)
  build {
    # Install and test backend
    step {
      name = "node:20-alpine"
      entrypoint = "npm"
      args = ["ci"]
      dir = "backend"
      id = "install-backend"
    }

    step {
      name = "node:20-alpine"
      entrypoint = "npm"
      args = ["run", "lint"]
      dir = "backend"
      id = "lint-backend"
      wait_for = ["install-backend"]
    }

    step {
      name = "node:20-alpine"
      entrypoint = "npm"
      args = ["test"]
      dir = "backend"
      env = ["NODE_ENV=test"]
      id = "test-backend"
      wait_for = ["install-backend"]
    }

    # Flutter analysis and testing
    step {
      name = "cirrusci/flutter:stable"
      entrypoint = "flutter"
      args = ["pub", "get"]
      dir = "mobile"
      id = "flutter-deps"
    }

    step {
      name = "cirrusci/flutter:stable"
      entrypoint = "flutter"
      args = ["analyze"]
      dir = "mobile"
      id = "flutter-analyze"
      wait_for = ["flutter-deps"]
    }

    step {
      name = "cirrusci/flutter:stable"
      entrypoint = "flutter"
      args = ["test"]
      dir = "mobile"
      id = "flutter-test"
      wait_for = ["flutter-deps"]
    }

    # Build options
    options {
      logging = "CLOUD_LOGGING_ONLY"
      machine_type = "E2_STANDARD_2"
    }

    # Tags for build organization
    tags = [
      "viatra-platform",
      "pr-validation",
      var.environment
    ]
  }

  # Dependencies
  depends_on = [
    google_service_account.cloud_build,
    google_project_iam_member.cloud_build_run_admin
  ]

  # Labels for resource organization
  labels = merge(var.labels, {
    environment = var.environment
    service     = "cicd"
    trigger     = "pull-request"
  })
}
