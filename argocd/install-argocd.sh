#!/bin/bash

# Script להתקנת ArgoCD על EKS cluster
# עונה על Setup Requirements: "Deploy hello-world-node using ArgoCD"

set -e

echo "🚀 מתקין ArgoCD על EKS cluster..."

# הוספת ArgoCD Helm repository
echo "📦 מוסיף ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# התקנת ArgoCD
echo "🔧 מתקין ArgoCD..."
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 8.1.3 \
  --set server.extraArgs="{--insecure,--disable-auth}" \
  --set server.service.type=ClusterIP \
  --wait

# המתנה לזמינות ArgoCD
echo "⏳ ממתין לזמינות ArgoCD..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# קבלת סיסמה ראשונית
echo "🔑 סיסמה ראשונית ל-ArgoCD:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# יצירת ServiceAccount עבור ArgoCD
echo "👤 יוצר ServiceAccount עבור ArgoCD..."
kubectl apply -f serviceaccount.yaml

echo "✅ ArgoCD הותקן בהצלחה!"

# הוראות גישה
echo ""
echo "🌐 הוראות גישה ל-ArgoCD:"
echo "1. הרץ את הפקודה הבאה בטרמינל נפרד:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:80"
echo ""
echo "2. פתח דפדפן וגש ל:"
echo "   http://localhost:8080"
echo ""
echo "🔑 פרטי התחברות:"
echo "   משתמש: admin"
echo "   סיסמה: (מוצגת למעלה)"
echo ""
echo "💡 טיפ: אם פורט 8080 תפוס, השתמש בפורט אחר:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8081:80"