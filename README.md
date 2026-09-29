# Terraform AWS Production Platform

Production-oriented AWS infrastructure built with Terraform, focusing on modularity, security, private networking, observability, environment isolation, and Infrastructure as Code best practices.

This project is being developed incrementally as a hands-on DevOps platform, with each infrastructure capability validated before moving to the next stage.

## Objectives

The project demonstrates how to:

- Build reusable Terraform modules
- Provision AWS infrastructure using Infrastructure as Code
- Separate DEV and PROD environments
- Manage Terraform state remotely and securely
- Apply least-privilege IAM principles
- Deploy workloads into private AWS subnets
- Manage EC2 instances without SSH or public IP addresses
- Access AWS services privately through VPC endpoints
- Manage application secrets securely
- Implement CloudWatch observability
- Automate Terraform validation and planning with GitHub Actions
- Integrate infrastructure security scanning
- Implement infrastructure testing
- Simulate infrastructure failures and recovery scenarios

---

## Architecture

The current DEV architecture is based on a multi-AZ VPC in AWS `eu-west-3`.

```text
                         AWS eu-west-3
                              │
                              ▼
                    ┌───────────────────┐
                    │        VPC        │
                    │    10.0.0.0/16    │
                    └─────────┬─────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
       Public Subnets                  Private Subnets
       10.0.1.0/24                     10.0.11.0/24
       10.0.2.0/24                     10.0.12.0/24
              │                               │
              ▼                               ▼
       Internet Gateway                  Private EC2
                                         No public IP
                                         No SSH
                                         IMDSv2
                                         Encrypted EBS
                                              │
                      ┌───────────────────────┼───────────────────────┐
                      │                       │                       │
                      ▼                       ▼                       ▼
                    SSM                  CloudWatch                  S3
             Interface Endpoints     Interface Endpoints       Gateway Endpoint
                      │                       │                       │
                      ▼                       ▼                       ▼
              Session Manager          Metrics / Logs       Bootstrap Artifacts
```

The private compute layer does not require a NAT Gateway.

AWS service connectivity is provided through VPC endpoints instead of general outbound Internet access.

---

## Networking

The VPC module currently provisions:

- Multi-AZ VPC
- Two public subnets
- Two private subnets
- Internet Gateway
- Public route table
- Dedicated private route tables
- Route table associations
- Environment and tier tagging

### DEV CIDR Layout

| Resource | CIDR |
|---|---|
| VPC | `10.0.0.0/16` |
| Public subnet 1 | `10.0.1.0/24` |
| Public subnet 2 | `10.0.2.0/24` |
| Private subnet 1 | `10.0.11.0/24` |
| Private subnet 2 | `10.0.12.0/24` |

The architecture intentionally avoids a NAT Gateway at the current stage.

---

## Private AWS Connectivity

Private EC2 instances access required AWS services through VPC endpoints.

### Interface Endpoints

The platform currently supports private connectivity to:

- AWS Systems Manager
- Systems Manager Messages
- CloudWatch Monitoring
- CloudWatch Logs

### S3 Gateway Endpoint

An S3 Gateway Endpoint provides private S3 connectivity from the private subnets.

The EC2 security group allows HTTPS traffic to the AWS-managed S3 prefix list instead of allowing unrestricted Internet egress.

This path is used during instance bootstrap to retrieve the Amazon CloudWatch Agent package.

---

## Compute Security

The compute module is designed around private EC2 instances.

Current controls include:

- No public IP address
- No inbound SSH access
- No port `22`
- AWS Systems Manager for administration
- IAM instance profile
- IMDSv2 required
- Encrypted `gp3` root volume
- Security-group-based service communication
- Conditional deployment for cost-controlled DEV testing

Compute resources can be enabled or disabled using Terraform configuration.

---

## Systems Manager

EC2 administration is performed using AWS Systems Manager Session Manager.

This removes the need for:

- SSH keys
- Bastion hosts
- Public EC2 addresses
- Inbound SSH security-group rules

The private SSM architecture has been validated successfully with the EC2 instance registering as:

```text
PingStatus: Online
Platform: Amazon Linux
```

---

## Secrets Management

Application secret access is designed around AWS Systems Manager Parameter Store.

Terraform manages:

- IAM permissions
- Parameter namespace access
- Role-policy attachments

Terraform intentionally does **not** manage real secret values.

This prevents application secret material from being stored in Terraform state.

DEV EC2 access is restricted to the environment-specific namespace:

```text
/production-platform/dev/*
```

---

## Observability

The platform includes a reusable CloudWatch observability module.

### CloudWatch Logs

Terraform provisions:

- Application CloudWatch Log Group
- Configurable log retention
- Least-privilege IAM permissions for log publishing

Example DEV log group:

```text
/production-platform/dev/application
```

### CloudWatch Metrics

The EC2 instance publishes custom operating-system metrics using the Amazon CloudWatch Agent.

Current metrics include:

```text
mem_used_percent
disk_used_percent
```

Metrics use the environment-specific namespace:

```text
production-platform/dev
```

The CloudWatch Agent is installed automatically during EC2 bootstrap.

The installation package is retrieved privately through the S3 Gateway Endpoint.

The complete telemetry path has been validated successfully:

```text
Private EC2
    │
    ▼
CloudWatch Agent
    │
    ▼
CloudWatch Monitoring VPC Endpoint
    │
    ▼
production-platform/dev
    │
    ├── mem_used_percent
    └── disk_used_percent
```

Actual memory datapoints have been successfully published and retrieved from CloudWatch.

### CloudWatch Alarms

Conditional EC2 alarms are defined for:

- High CPU utilization
- EC2 status-check failures

The alarms are created only when compute resources are enabled.

---

## IAM and Least Privilege

The platform uses dedicated IAM roles and policies rather than embedding AWS credentials in EC2 instances.

Current permissions include:

- Systems Manager managed-instance access
- Environment-scoped Parameter Store reads
- CloudWatch Logs publishing
- CloudWatch custom metric publishing

CloudWatch `PutMetricData` access is restricted using the CloudWatch namespace:

```text
production-platform/dev
```

No long-lived AWS credentials are stored on the EC2 instance.

---

## Terraform Remote State

Application infrastructure state is stored remotely in Amazon S3.

The state bucket is bootstrapped separately and includes:

- S3 versioning
- Server-side encryption
- Public access blocking
- Terraform state locking support

DEV and PROD use separate state keys:

```text
dev/terraform.tfstate
prod/terraform.tfstate
```

Bootstrap state remains separate from application infrastructure state.

---

## Environment Isolation

The repository separates environment configuration:

```text
environments/
├── dev/
└── prod/
```

DEV and PROD have independent:

- Terraform backend state
- CIDR ranges
- Environment variables
- Resource naming
- Observability configuration
- Secret namespaces

PROD infrastructure is currently validated through Terraform planning but is not deployed.

---

## Repository Structure

```text
.
├── bootstrap/
├── environments/
│   ├── dev/
│   └── prod/
├── modules/
│   ├── compute/
│   ├── iam/
│   ├── observability/
│   ├── secrets/
│   ├── security/
│   ├── vpc/
│   └── vpc-endpoints/
├── .gitignore
├── .terraform-version
├── .terraform.lock.hcl
└── README.md
```

---

## Current Project Status

### Completed

- [x] Terraform project bootstrap
- [x] AWS provider configuration
- [x] Multi-AZ VPC
- [x] Public and private subnets
- [x] Internet Gateway and routing
- [x] Reusable Terraform modules
- [x] IAM instance role and profile
- [x] Security groups
- [x] Private EC2 compute module
- [x] IMDSv2 enforcement
- [x] Encrypted EBS
- [x] S3 remote Terraform state
- [x] DEV / PROD environment separation
- [x] Parameter Store least-privilege access
- [x] SSM private administration
- [x] SSM VPC endpoints
- [x] S3 Gateway Endpoint
- [x] CloudWatch private endpoints
- [x] CloudWatch Logs configuration
- [x] CloudWatch Agent automated bootstrap
- [x] Custom memory and disk metrics
- [x] Conditional EC2 CloudWatch alarms
- [x] End-to-end private observability validation

### Next

- [ ] Deploy application workload
- [ ] Application Load Balancer
- [ ] Application health checks
- [ ] Runtime secret retrieval
- [ ] Application log forwarding
- [ ] GitHub Actions Terraform CI/CD
- [ ] GitHub Actions AWS authentication using OIDC
- [ ] Infrastructure security scanning
- [ ] Terraform policy validation
- [ ] Infrastructure testing
- [ ] Failure and recovery simulations

---

## Technologies

- Terraform
- AWS
- Amazon VPC
- Amazon EC2
- AWS IAM
- AWS Systems Manager
- AWS PrivateLink / VPC Endpoints
- Amazon S3
- Amazon CloudWatch
- Linux
- GitHub Actions

---

## Security Principles

The project follows several production-oriented security principles:

- Least-privilege IAM
- Private-by-default compute
- No SSH administration
- No public EC2 IP addresses
- IMDSv2 enforcement
- Encrypted storage
- Environment isolation
- Remote and encrypted Terraform state
- No secrets stored in Terraform state
- Restricted security-group egress
- Private AWS service connectivity
- Infrastructure managed exclusively through Terraform

---

## Development Approach

Infrastructure changes follow a controlled workflow:

```text
terraform fmt
        ↓
terraform validate
        ↓
terraform plan
        ↓
Review
        ↓
terraform apply
        ↓
Runtime validation
```

Runtime resources such as EC2 instances and Interface VPC Endpoints can remain disabled when not required, allowing the DEV environment to retain its infrastructure foundation while minimizing unnecessary AWS costs.