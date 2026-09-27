terraform {
  backend "s3" {
    bucket       = "terraform-aws-production-platform-state-bootstrap"
    key          = "prod/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}