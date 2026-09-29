resource "aws_cloudwatch_log_group" "application" {
  name = "/${var.name}/${var.environment}/application"

  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.name}-${var.environment}-application-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    sid    = "WriteApplicationLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.application.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${var.name}-${var.environment}-cloudwatch-logs"
  description = "Allow application instances to write application logs to CloudWatch"

  policy = data.aws_iam_policy_document.cloudwatch_logs.json

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = var.ec2_role_name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.compute_enabled ? 1 : 0

  alarm_name        = "${var.name}-${var.environment}-ec2-high-cpu"
  alarm_description = "EC2 CPU utilization is above ${var.cpu_alarm_threshold}%"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  statistic = "Average"
  period    = 300

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "missing"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  count = var.compute_enabled ? 1 : 0

  alarm_name        = "${var.name}-${var.environment}-ec2-status-check-failed"
  alarm_description = "EC2 instance or system status check has failed"

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed"

  statistic = "Maximum"
  period    = 60

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "missing"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "cloudwatch_metrics" {
  statement {
    sid    = "PublishApplicationMetrics"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"

      values = [
        "${var.name}/${var.environment}"
      ]
    }
  }
}

resource "aws_iam_policy" "cloudwatch_metrics" {
  name        = "${var.name}-${var.environment}-cloudwatch-metrics"
  description = "Allow application instances to publish CloudWatch metrics"

  policy = data.aws_iam_policy_document.cloudwatch_metrics.json

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_metrics" {
  role       = var.ec2_role_name
  policy_arn = aws_iam_policy.cloudwatch_metrics.arn
}