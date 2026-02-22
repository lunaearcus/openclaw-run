locals {
  image_name = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ghcr_proxy.repository_id}/openclaw/openclaw:latest"
}

resource "google_artifact_registry_repository" "ghcr_proxy" {
  project       = var.project_id
  location      = var.region
  repository_id = "ghcr-proxy"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  description   = "Proxy for GitHub Container Registry"

  remote_repository_config {
    docker_repository {
      custom_repository {
        uri = "https://ghcr.io"
      }
    }
  }
}
resource "google_storage_bucket" "data" {
  name          = "${var.project_id}-openclaw-storage"
  location      = var.region
  force_destroy = false
}
resource "google_service_account" "sa" {
  account_id = "openclaw-runner"
}
resource "google_project_iam_member" "vertex" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.sa.email}"
}
resource "google_storage_bucket_iam_member" "storage" {
  bucket = google_storage_bucket.data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.sa.email}"
}
resource "google_cloud_run_v2_service" "openclaw" {
  provider            = google-beta
  name                = "openclaw-service"
  project             = var.project_id
  location            = var.run_region
  deletion_protection = false
  launch_stage        = "BETA"

  scaling {
    min_instance_count = 0
    max_instance_count = 1
  }

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    service_account       = google_service_account.sa.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = local.image_name
      ports {
        container_port = 18789
      }
      resources {
        limits = {
          cpu    = "1"
          memory = "1024Mi"
        }
      }
      command = ["/bin/sh"]
      args = [
        "-c",
        <<-EOT
        mkdir -p /home/node/.openclaw && \
        cp -rn /mnt/.openclaw/. /home/node/.openclaw/ 2>/dev/null || true && \
        echo '🦞 Sync complete. Starting Gateway...' && \
        /usr/local/bin/docker-entrypoint.sh node dist/index.js gateway
        EOT
      ]
      env {
        name  = "NODE_OPTIONS"
        value = "--max-old-space-size=768"
      }
      env {
        name  = "HOME"
        value = "/home/node"
      }
      env {
        name  = "OPENCLAW_NO_BROWSER"
        value = "true"
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "GOOGLE_CLOUD_LOCATION"
        value = var.run_region
      }

      volume_mounts {
        name       = "openclaw"
        mount_path = "/mnt/.openclaw"
      }
    }

    volumes {
      name = "openclaw"
      gcs {
        bucket    = google_storage_bucket.data.name
        read_only = false
      }
    }
  }
}
