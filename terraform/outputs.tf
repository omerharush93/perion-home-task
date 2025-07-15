output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = var.cluster_version
}

output "node_group_ami_type" {
  description = "AMI type used for node groups"
  value       = "AL2023_x86_64_STANDARD"
}

output "owner" {
  description = "Project owner"
  value       = "omer"
}

output "ecr_repository_url" {
  description = "ECR repository URL for hello-world-node"
  value       = aws_ecr_repository.hello_world_node.repository_url
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler IAM role"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI Driver IAM role"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN for IRSA"
  value       = data.aws_iam_openid_connect_provider.this.arn
}