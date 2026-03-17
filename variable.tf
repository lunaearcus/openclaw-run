variable "project_id" {
  type        = string
  description = "The ID of the project in which to create resources."
  default     = "YOUR_PROJECT_ID"
}
variable "region" {
  type        = string
  description = "The region in which to create resources."
  default     = "us-central1"
}
variable "billing_id" {
  type        = string
  description = "The billing ID for the project."
  default     = "000000-000000-000000"
}
variable "my_email" {
  type        = string
  description = "The email address of the user."
  default     = "your-email@gmail.com"
}
variable "wakeup_schedule" {
  type        = string
  description = "The cron schedule for waking up the service."
  default     = "30 1-23/4 * * *"
}
variable "manual_instance_count" {
  type        = number
  description = "Manual instance count."
  default     = null
}
variable "iap_client_id" {
  type        = string
  description = "Client ID for Cloud Run Direct IAP"
}
