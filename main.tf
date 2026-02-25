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
  name                        = "${var.project_id}-openclaw-data"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}
resource "google_service_account" "sa" {
  account_id = "openclaw-runner"
}
resource "google_project_iam_binding" "aiplatform-user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  members = [google_service_account.sa.member]
}
resource "google_storage_bucket_iam_member" "storage" {
  bucket = google_storage_bucket.data.name
  role   = "roles/storage.objectAdmin"
  member = google_service_account.sa.member
}
resource "google_cloud_run_v2_service" "openclaw" {
  provider            = google-beta
  name                = "openclaw-service"
  project             = var.project_id
  location            = var.region
  deletion_protection = false
  launch_stage        = "GA"

  scaling {
    min_instance_count = 0
    max_instance_count = 1
  }

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    service_account       = google_service_account.sa.email

    containers {
      image = "${google_artifact_registry_repository.ghcr_proxy.registry_uri}/openclaw/openclaw:latest"
      ports {
        container_port = 18789
      }
      resources {
        limits = {
          cpu    = "2"
          memory = "2048Mi"
        }
      }
      command = ["/bin/sh"]
      args = [
        "-c",
        <<-EOT
        ln -s /mnt/.openclaw /home/node/.openclaw && \
        echo '🦞 Sync complete. Starting Gateway...' && \
        /usr/local/bin/docker-entrypoint.sh node dist/index.js gateway
        EOT
      ]
      env {
        name  = "NODE_OPTIONS"
        value = "--max-old-space-size=1536"
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
        value = var.region
      }

      volume_mounts {
        name       = "openclaw"
        mount_path = "/mnt/.openclaw"
      }
    }

    volumes {
      name = "openclaw"
      gcs {
        bucket        = google_storage_bucket.data.name
        read_only     = false
        mount_options = ["file-mode=777", "dir-mode=777", "uid=1000", "gid=1000", "metadata-cache-ttl-secs=120", "stat-cache-max-size-mb=32", "type-cache-max-size-mb=4"]
      }
    }
  }
}
