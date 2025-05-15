variable "alert_email" {
  description = "Email address for SNS notifications"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to stop"
  type        = list(string)
}

variable "stop_hour" {
  description = "Hour in UTC for daily stop (0-23)"
  type        = number
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "stop-ec2-and-notify"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}