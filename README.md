# DevOps & Cloud Infrastructure

Terraform scripts, GitHub Actions CI/CD pipelines, and Docker configurations for deploying Java Spring Boot applications to AWS. Captures the infrastructure and deployment patterns from production work at Mutual of Omaha.

[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=flat-square&logo=terraform)](https://terraform.io)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?style=flat-square&logo=github-actions)](https://github.com/features/actions)
[![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20S3%20%7C%20RDS-FF9900?style=flat-square&logo=amazonaws)](https://aws.amazon.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker)](https://docker.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes)](https://kubernetes.io)

## What's In Here

This repo is organized into three areas:

1. **Terraform** - Infrastructure as Code to provision repeatable AWS environments (EC2, S3, RDS, VPC)
2. **GitHub Actions / Jenkins** - CI/CD pipelines to build, test, dockerize, and deploy Spring Boot apps
3. **Kubernetes** - K8s manifests for container orchestration (learning/reference)

**Based on real work:** The CI/CD patterns here reflect pipelines I built and maintained at Mutual of Omaha (2022-2025), where I deployed Java microservices to EC2, managed Docker-based workflows, and used GitHub Actions for automated build-test-deploy on every push to main.

## CI/CD Pipeline

```
Developer pushes to main branch
        |
        v
GitHub Actions triggered
        |
        |-- 1. Run unit tests (Maven)
        |       |-- Fail? -> notify, block deploy
        |
        |-- 2. Run integration tests (Testcontainers)
        |
        |-- 3. Build Docker image (multi-stage Dockerfile)
        |       |-- Stage 1: Maven build + test
        |       |-- Stage 2: minimal JRE runtime image
        |
        |-- 4. Push image to Docker Hub / AWS ECR
        |
        |-- 5. Deploy to EC2 (SSH + docker pull + restart)
                |
                v
             Production running
```

**On pull requests:** Run tests only (no deploy). Block merge if tests fail.

## Terraform Infrastructure

```
terraform/
|-- main.tf         # provider config and main resources
|-- variables.tf    # input variables (region, instance type, etc.)
|-- outputs.tf      # output values (EC2 public IP, RDS endpoint, etc.)
|-- ec2.tf          # EC2 instance, security groups, key pair
|-- rds.tf          # PostgreSQL RDS instance, subnet group
|-- s3.tf           # S3 buckets for assets and deployment artifacts
|-- vpc.tf          # VPC, subnets, internet gateway, route tables
```

**What it provisions:**

| Resource | Details |
|---|---|
| EC2 | t3.medium, Amazon Linux 2, auto-assigned Elastic IP |
| RDS | PostgreSQL 15, db.t3.micro, private subnet |
| S3 | Two buckets: static assets + deployment artifacts |
| VPC | Custom VPC with public/private subnets across 2 AZs |
| Security Groups | EC2 allows 80/443/22 inbound; RDS allows 5432 from EC2 only |

### Getting Started with Terraform

```bash
# Prerequisites: Terraform >= 1.5, AWS CLI configured
cd terraform/
terraform init
terraform plan    # review changes
terraform apply   # provision infrastructure
```

Outputs after apply:
```
ec2_public_ip = "52.x.x.x"
rds_endpoint  = "myapp.xxxx.us-east-1.rds.amazonaws.com"
s3_bucket     = "myapp-assets-prod"
```

## GitHub Actions Workflows

```yaml
# .github/workflows/deploy.yml
name: Build, Test, and Deploy
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with: {java-version: '17'}
      - run: mvn test

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - run: docker build -t myapp .
      - run: docker push $ECR_REGISTRY/myapp:latest
      - run: ssh ec2-user@$EC2_IP 'docker pull ... && docker-compose up -d'
```

## Docker Configuration

Multi-stage Dockerfile keeps production images lean:

```dockerfile
# Stage 1: Build
FROM maven:3.9-amazoncorretto-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src/ src/
RUN mvn package -DskipTests

# Stage 2: Runtime (minimal image)
FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Result: production image is ~180MB instead of ~600MB with full Maven.

## Kubernetes (Reference)

K8s manifests for containerized deployments:

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-boot-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: spring-boot-app
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_DATASOURCE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
```

## What I'd Add Next

- **Blue/green deployment** - deploy new version alongside old, switch traffic after health checks pass
- **Secrets management** - integrate AWS Secrets Manager with Terraform instead of environment variable secrets
- **Monitoring** - add CloudWatch alarms for CPU, memory, and error rate; set up dashboards
- **Cost optimization** - add Auto Scaling Groups to EC2 so capacity scales with traffic
- **GitOps** - ArgoCD for Kubernetes deployments instead of SSH-based deploy scripts

## Related Projects

- [Banking Transaction Microservices](https://github.com/Rajeshdevandla/banking-transaction-microservices) - Java microservices this infrastructure deploys
- [Insurance Customer Portal](https://github.com/Rajeshdevandla/insurance-customer-portal) - Full-stack Angular + Spring Boot app
- [AI Document Intelligence Platform](https://github.com/Rajeshdevandla/ai-document-intelligence-platform) - Multi-service deployment on AWS

---

Built by [Rajesh Kumar](https://rajeshdevandla.github.io) - Full Stack Java & AI Developer | Chicago, IL# DevOps & Cloud Infrastructure


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
