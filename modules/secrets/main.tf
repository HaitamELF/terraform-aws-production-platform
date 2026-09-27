data "aws_iam_policy_document" "parameter_store_read" {
  statement {
    sid    = "ReadApplicationParameters"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.name}/${var.environment}/*"
    ]
  }
}

resource "aws_iam_policy" "parameter_store_read" {
  name = "${var.name}-${var.environment}-parameter-store-read"

  description = "Allow application instances to read their SSM parameters"
  policy      = data.aws_iam_policy_document.parameter_store_read.json

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "parameter_store_read" {
  role       = var.ec2_role_name
  policy_arn = aws_iam_policy.parameter_store_read.arn
}