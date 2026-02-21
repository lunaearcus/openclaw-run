resource "google_billing_budget" "budget" {
  billing_account = var.billing_id
  display_name    = "OpenClaw-Budget-Control"

  amount {
    specified_amount {
      currency_code = "JPY"
      units         = "1000"
    }
  }

  threshold_rules { threshold_percent = 0.3 } # 300円
  threshold_rules { threshold_percent = 0.5 } # 500円
  threshold_rules { threshold_percent = 1.0 } # 1000円
  lifecycle {
    prevent_destroy = true
  }
}
