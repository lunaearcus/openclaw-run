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
