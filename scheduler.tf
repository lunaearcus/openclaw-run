resource "google_service_account" "scheduler" {
  account_id = "openclaw-scheduler"
}
resource "google_project_iam_binding" "run-invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  members = [google_service_account.scheduler.member]
}
resource "google_cloud_scheduler_job" "scheduler" {
  name             = "openclaw-scheduler"
  schedule         = "40 3-23/4 * * *"
  time_zone        = "Asia/Tokyo"
  attempt_deadline = "60s"
  region           = var.run_region

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = google_cloud_run_v2_service.openclaw.uri
    oidc_token {
      service_account_email = google_service_account.scheduler.email
    }
  }
}
