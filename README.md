# DevOps & Cloud Infrastructure

End-to-end cloud infrastructure and CI/CD automation managing multi-region AWS deployments with real-time monitoring and alerting.

## Key Achievements
- Orchestrated **Docker/Kubernetes** across **3 AWS regions** (us-east-1, us-west-2, eu-west-1)
- Automated **100%** of deployment pipeline — zero manual steps
- Reduced **incident response time by 45%** with real-time alerting

## Tech Stack
| Domain | Technologies |
|---|---|
| IaC | Terraform, AWS CloudFormation |
| Containers | Docker, Kubernetes (EKS) |
| CI/CD | Jenkins, GitHub Actions |
| Monitoring | CloudWatch, Grafana, Prometheus |
| Config Mgmt | Ansible |
| Cloud | AWS (EKS, ECS, RDS, S3, CloudFront, Route53) |

## Infrastructure Overview
```
GitHub → GitHub Actions → ECR
                       → EKS (us-east-1)   ─┐
                       → EKS (us-west-2)   ─┼─ Route53 (Geo-routing)
                       → EKS (eu-west-1)   ─┘
                              ↓
                    CloudWatch + Grafana monitoring
```

## Quick Start
```bash
cd terraform/
terraform init && terraform plan && terraform apply
```
