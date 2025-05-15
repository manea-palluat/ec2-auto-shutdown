terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

#sns + email
resource "aws_sns_topic" "notify" {
  name = "ec2-shutdown-notify"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.notify.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

#IAM role for lambda
resource "aws_iam_role" "lambda_role" {
  name = "ec2-shutdown-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = ["ec2:DescribeInstanceStatus", "ec2:StopInstances"],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = aws_sns_topic.notify.arn
      }
    ]
  })
}

#package the Python
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

#lambda function
resource "aws_lambda_function" "stop_and_notify" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "stop-ec2-and-notify"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notify.arn
      INSTANCE_IDS  = join(",", var.instance_ids)
    }
  }
}

#allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_and_notify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

#schedule daily stop
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "daily-stop-ec2"
  schedule_expression = var.stop_cron_expr
}

resource "aws_cloudwatch_event_target" "invoke" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.stop_and_notify.arn
}
