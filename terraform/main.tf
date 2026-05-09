terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "devops-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

# ── VPC ──────────────────────────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "${var.project_name}-vpc-${var.environment}"
  cidr    = var.vpc_cidr
  azs     = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = false
  enable_dns_hostnames   = true
  tags = local.common_tags
}

# ── EKS Cluster ──────────────────────────────────────────
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  eks_managed_node_groups = {
    general = {
      instance_types = ["m5.xlarge"]
      min_size       = 3
      max_size       = 10
      desired_size   = 3
      labels = { role = "general" }
    }
    compute = {
      instance_types = ["c5.2xlarge"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2
      labels = { role = "compute" }
      taints = [{ key = "dedicated", value = "compute", effect = "NO_SCHEDULE" }]
    }
  }
  tags = local.common_tags
}

# ── RDS PostgreSQL ────────────────────────────────────────
module "rds" {
  source              = "terraform-aws-modules/rds/aws"
  version             = "~> 6.0"
  identifier          = "${var.project_name}-${var.environment}"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = var.db_instance_class
  allocated_storage   = 100
  storage_encrypted   = true
  db_name             = var.db_name
  username            = var.db_username
  password            = random_password.db_password.result
  multi_az            = true
  deletion_protection = var.environment == "prod"
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  tags = local.common_tags
}

# ── S3 for Artifacts ─────────────────────────────────────
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts-${var.environment}-${data.aws_caller_identity.current.account_id}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration { status = "Enabled" }
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Rajesh Kumar"
  }
}
