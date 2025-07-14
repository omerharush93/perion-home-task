terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95, < 6.0.0"
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
