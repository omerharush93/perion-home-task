#!/bin/bash

# Script להקמת תשתית Perion עם Terraform
# עונה על Task 1 מהמטלה: VPC + EKS cluster

set -e

echo "🚀 מתחיל הקמת תשתית Perion..."

# בדיקת התקנות
echo "📋 בודק התקנות..."
terraform --version
aws --version
kubectl version --client


# אתחול Terraform
echo "🔧 מאתחל Terraform..."
terraform init

# תכנון Terraform
echo "📝 מתכנן תשתית..."
terraform plan -out=tfplan

# אישור והרצה
echo "⚠️  האם להמשיך עם הקמת התשתית? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🏗️  מקים תשתית..."
    terraform apply tfplan
else
    echo "❌ ביטול הקמת תשתית"
    exit 1
fi

# עדכון kubeconfig
echo "🔗 מעדכן kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name omer-perion-cluster

# בדיקת cluster
echo "✅ בודק cluster..."
kubectl cluster-info
kubectl get nodes

echo "🎉 תשתית הוקמה בהצלחה!"
echo "📊 Cluster endpoint: $(terraform output -raw cluster_endpoint)"
echo "🔗 ECR Repository: $(terraform output -raw ecr_repository_url)" 