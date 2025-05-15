#outputs for the SNS topic and Lambda function

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.notify.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.stop_and_notify.function_name
}