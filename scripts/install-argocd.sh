#!/bin/bash

# Script to install ArgoCD on EKS cluster
# Implements Setup Requirements: "Deploy hello-world-node using ArgoCD"

set -e

cd "$(dirname "$0")/../argocd"

echo "🚀 Installing ArgoCD on EKS cluster..."

# Add ArgoCD Helm repository
echo "📦 Adding ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install ArgoCD
echo "🔧 Installing ArgoCD..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 8.1.3 \
  --set server.extraArgs="{--insecure,--disable-auth}" \
  --set server.service.type=ClusterIP \
  --wait

# Wait for ArgoCD availability
echo "⏳ Waiting for ArgoCD to become available..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get initial password
echo "🔑 Initial ArgoCD password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Create ServiceAccount for ArgoCD
echo "👤 Creating ServiceAccount for ArgoCD..."
kubectl apply -f serviceaccount.yaml

echo "✅ ArgoCD installed successfully!"

# Configure Application (if file exists)
if [ -f "hello-world-app.yaml" ]; then
    echo "📋 Configuring Application in ArgoCD..."
    kubectl apply -f hello-world-app.yaml
    echo "✅ Application configured!"
else
    echo "⚠️  hello-world-app.yaml file not found"
    echo "   Configure the application manually via UI or CLI"
fi

# Access instructions
echo ""
echo "🌐 Access instructions for ArgoCD:"
echo "1. Run the following command in a separate terminal:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:80"