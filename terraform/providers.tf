terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95, < 6.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"  # גרסה עדכנית ליולי 2025
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "perion-home-task"
      ManagedBy   = "terraform"
      Owner       = "omer"
      CreatedAt   = "2025-07"
    }
  }
}
