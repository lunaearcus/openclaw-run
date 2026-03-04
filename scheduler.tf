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
  schedule         = var.wakeup_schedule
  time_zone        = "Etc/UTC"
  attempt_deadline = "60s"
  region           = var.region

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = google_cloud_run_v2_service.openclaw.uri
    oidc_token {
      audience              = "${google_cloud_run_v2_service.openclaw.uri}/"
      service_account_email = google_service_account.scheduler.email
    }
  }
}
