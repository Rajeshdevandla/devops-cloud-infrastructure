# DevOps & Cloud Infrastructure

A collection of Terraform and CI/CD configurations for deploying Java Spring Boot applications to AWS using Docker and GitHub Actions.

This is a portfolio project that captures the infrastructure and deployment patterns I've worked with — including the CI/CD pipelines I built and maintained at Mutual of Omaha.

## What's In Here

- Terraform scripts to provision AWS infrastructure (EC2, S3, RDS, VPC)
- GitHub Actions workflows to build, test, dockerize, and deploy Spring Boot apps
- Docker Compose setup for local development with multiple services
- Kubernetes manifests for container orchestration (learning/reference)

## Tech Stack

| Domain | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Containers | Docker, Docker Compose |
| Orchestration | Kubernetes (K8s) |
| CI/CD | GitHub Actions, Jenkins |
| Cloud | AWS (EC2, S3, RDS, VPC) |
| Monitoring | CloudWatch |

## CI/CD Pipeline

```
GitHub Push → GitHub Actions
             → Run unit tests (Maven)
             → Build Docker image
             → Push to Docker Hub / ECR
             → Deploy to EC2
```

## Terraform Structure

```
terraform/
├── main.tf          — provider config and main resources
├── variables.tf     — input variables
├── outputs.tf       — output values
├── ec2.tf           — EC2 instance and security groups
├── rds.tf           — PostgreSQL RDS instance
└── s3.tf            — S3 buckets for assets and deployments
```

## Getting Started

Prerequisites: Terraform, AWS CLI, Docker

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

## What I Applied Here

- Writing Terraform to provision repeatable AWS environments
- GitHub Actions for automated build → test → deploy pipelines
- Docker multi-stage builds to keep images lean
- Environment variable management across dev and prod configs

## Background

Based on real CI/CD and deployment work at Mutual of Omaha where I built and maintained Jenkins and GitHub Actions pipelines, deployed to EC2/S3, and worked with Docker-based deployment workflows.

---

**Rajesh Kumar** — Full Stack Java Developer | Chicago, IL
[Portfolio](https://rajeshdevandla.github.io) · [GitHub](https://github.com/Rajeshdevandla)
