variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address for notifications"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs"
  type        = list(string)
}

variable "stop_cron_expr" {
  description = "Cron expression in UTC for daily stop"
  type        = string
}
