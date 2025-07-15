# VPC Module - AWS Official Module (Updated Version)
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags for EKS
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = {
    Environment = var.environment
    Project     = "perion-home-task"
    ManagedBy   = "terraform"
    Owner       = "omer"
  }
}

# EKS Module - AWS Official Module (Updated Version)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  enable_irsa = true
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    omer-general = {
      min_size     = 2
      max_size     = 10
      desired_size = 2

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      tags = {
        ExtraTag = "omer-node-group"
        "k8s.io/cluster-autoscaler/enabled"                = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}"    = "owned"
      }
    }
  }
  # הפעלה של גישה מכניסת היוצר כ-admin
  enable_cluster_creator_admin_permissions = true

  # הגדרת access entries למשתמש candidate-omer
  access_entries = {
    candidate_omer = {
      principal_arn = "arn:aws:iam::760370564012:user/candidate-omer"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
            namespaces = []
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns                = { most_recent = true }
    kube-proxy             = { most_recent = true } 
    vpc-cni                = { most_recent = true }
  }
  
  tags = {
    Environment = var.environment
    Project     = "perion-home-task"
    ManagedBy   = "terraform"
    Owner       = "omer"
  }
}

# ECR Repository for hello-world-node application
resource "aws_ecr_repository" "hello_world_node" {
  name                 = "omer/hello-world-node"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "hello-world-node-repo"
    Environment = var.environment
    Project     = "perion-home-task"
    ManagedBy   = "terraform"
    Owner       = "omer"
  }
}
