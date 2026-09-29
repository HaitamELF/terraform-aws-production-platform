data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  cloudwatch_agent_config = jsonencode({
    agent = {
      metrics_collection_interval = 60
    }

    metrics = {
      namespace = var.cloudwatch_namespace

      append_dimensions = {
        InstanceId = "$${aws:InstanceId}"
      }

      metrics_collected = {
        mem = {
          measurement = [
            "mem_used_percent"
          ]

          metrics_collection_interval = 60
        }

        disk = {
          measurement = [
            "used_percent"
          ]

          metrics_collection_interval = 60

          resources = [
            "/"
          ]
        }
      }
    }
  })

  user_data = templatefile(
    "${path.module}/user_data.sh.tftpl",
    {
      cloudwatch_agent_config = local.cloudwatch_agent_config
      aws_region              = var.aws_region
    }
  )
}

resource "aws_instance" "app" {
  count         = var.enabled ? 1 : 0
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = var.instance_profile_name

  associate_public_ip_address = false

  user_data = local.user_data

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8

    delete_on_termination = true
  }

  tags = {
    Name        = "${var.name}-${var.environment}-app"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}