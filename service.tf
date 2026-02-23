resource "google_project_service" "serviceusage" {
  project            = var.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}
locals {
  services = [
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "aiplatform.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "cloudscheduler.googleapis.com",
  ]
}
resource "google_project_service" "this" {
  for_each           = toset(local.services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = true
  depends_on         = [google_project_service.serviceusage]
}
