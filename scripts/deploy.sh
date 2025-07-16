#!/bin/bash

# Script to provision Perion infrastructure with Terraform
# Implements Task 1: VPC + EKS cluster

set -e

cd "$(dirname "$0")/../terraform"

echo "🚀 Starting Perion infrastructure provisioning..."

# Check installations
echo "📋 Checking installations..."
terraform --version
aws --version
kubectl version --client

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Terraform plan
echo "📝 Planning infrastructure..."
terraform plan -out=tfplan

# Approval and apply
echo "⚠️  Continue with infrastructure provisioning? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🏗️  Provisioning infrastructure..."
    terraform apply tfplan
else
    echo "❌ Infrastructure provisioning cancelled"
    exit 1
fi

# Update kubeconfig
echo "🔗 Updating kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name omer-perion-cluster

# Check cluster
echo "✅ Checking cluster..."
kubectl cluster-info
kubectl get nodes

echo "🎉 Infrastructure provisioned successfully!"
echo "📊 Cluster endpoint: $(terraform output -raw cluster_endpoint)"
echo "🔗 ECR Repository: $(terraform output -raw ecr_repository_url)" 