# 🚀 Perion DevOps Home Task - Complete Solution

## 📋 סקירה כללית

פרויקט DevOps מקיף עבור מטלת הבית של Perion, הכולל תשתית כקוד, פריסת אפליקציה ב-Kubernetes, CI/CD pipeline, ופתרון לבעיות ביצועים.

## 🎯 מטרות הפרויקט

### ✅ Task 1: Infrastructure as Code
- [x] **VPC** עם public/private subnets ב-2 AZs
- [x] **EKS cluster** עם managed node groups
- [x] **ECR repository** עם image scanning

### ✅ Task 2: Kubernetes Application Deployment
- [x] **הורדת אפליקציה** מ-S3
- [x] **CI/CD pipeline** עם GitHub Actions
- [x] **GitOps deployment** עם ArgoCD
- [x] **Logging stack** עם Loki + Grafana
- [x] **High Availability** עם multi-AZ
- [x] **KEDA ScaledObject** עם CPU(80%) + cron pre-scaling
- [x] **Cluster Autoscaler** לניהול Nodes

## 🏗️ ארכיטקטורה

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │   AWS ECR       │    │   EKS Cluster   │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ GitHub      │ │───▶│ │ Docker      │ │───▶│ │ ArgoCD      │ │
│ │ Actions     │ │    │ │ Images      │ │    │ │ Application │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    │                 │
                                              │ ┌─────────────┐ │
                                              │ │ Hello World │ │
                                              │ │ Node.js App │ │
                                              │ └─────────────┘ │
                                              │                 │
                                              │ ┌─────────────┐ │
                                              │ │ Loki        │ │
                                              │ │ Grafana     │ │
                                              │ └─────────────┘ │
                                              └─────────────────┘
```

## 🛠️ טכנולוגיות

| רכיב | גרסה | תפקיד |
|------|------|-------|
| **Terraform** | 1.12.2+ | Infrastructure as Code |
| **AWS Provider** | 6.3.0+ | AWS resources management |
| **EKS** | 1.33 | Kubernetes cluster |
| **ArgoCD** | 8.1.3 | GitOps deployment |
| **Loki** | 6.31.0 | Log aggregation |
| **GitHub Actions** |  | CI/CD pipeline |
| **Helm** | 3.18.4 | Package Manager |


## 🚀 התקנה והפעלה

### דרישות מוקדמות

```bash
# התקנת כלים נדרשים
./setup-requirements.md
```

### שלב 1: הקמת תשתית

```bash
cd terraform
chmod +x deploy.sh
./deploy.sh
```

### שלב 2: הורדת האפליקציה

```bash
chmod +x scripts/download-app.sh
./scripts/download-app.sh
```

### שלב 3: התקנת ArgoCD

```bash
chmod +x argocd/install-argocd.sh
./argocd/install-argocd.sh
```

### שלב 4: התקנת Logging Stack

```bash
chmod +x logging/install-loki.sh
./logging/install-loki.sh
```

### שלב 5: פריסת האפליקציה

```bash
helm upgrade --install hello-world-node ./helm/hello-world-node \
  --namespace default \
  --create-namespace
```

## 📊 Monitoring & Observability

### Logs
- **Loki**: איסוף לוגים מכל pods
- **Grafana**: visualization וניתוח


## ⚡ פתרון ביצועים - שעה 10:00

### הבעיה
כל בוקר בשעה 10:00 האפליקציה חווה עומס גבוה ולא מספיקה לסקייל מהר מספיק.

### הפתרון
1. **Pre-scaling**: CronJob שמריץ בשעה 9:00 ומעלה ל-6 replicas
3. **HPA**: סקיילינג מהיר לפי עומס במצב של 80% CPU
4. **Pod Anti-Affinity**: פיזור replicas על nodes שונים

```yaml
#  KEDA Scaler
 triggers:
 - type: cpu
   metadata:
     type: Utilization
     value: "80" # HPA on 80% CPU
 - type: cron
   metadata:
     timezone: Asia/Jerusalem
     start: "45 9 * * *" # Every Morning 9:45 AM Pre-scling to 6 replicas
     end: "0 13 * * *"
     desiredReplicas: "6"
```

## 🔐 אבטחה

### IAM & RBAC
- Principle of Least Privilege
- Service Accounts במקום IAM users


### Network Security
- Private subnets ל-EKS nodes
- Security Groups ספציפיים
- Network Policies בין pods

### Multi-AZ Deployment + High Availability
- Pod Anti-Affinity: pods לא על אותו node + לא על אותו AZ
- לפחות 3 replicas תמיד זמינים
- PDB
- Rolling Updates
- Cluster Autoscaler


### Rolling Updates
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 50%
    maxUnavailable: 0%
```

### Pod Disruption Budget
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
spec:
  minAvailable: 2
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
1. **Build**: בניית Docker image
2. **Test**: הרצת בדיקות
3. **Push**: דחיפה ל-ECR
4. **Deploy**: עדכון ArgoCD
5. **Verify**: בדיקת פריסה

### ArgoCD Integration
- GitOps deployment
- Automated sync
- Rollback capabilities
- Health monitoring

## 🧪 בדיקות

### בדיקת תשתית
```bash
terraform plan
kubectl get nodes
kubectl cluster-info
```

### בדיקת אפליקציה
```bash
kubectl get pods -l app=hello-world-node
kubectl get svc hello-world-node-service
```

### בדיקת ArgoCD
```bash
kubectl get applications -n argocd
argocd app sync hello-world-node

# גישה ל-ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:80
# פתח דפדפן: http://localhost:8080
# משתמש: admin, סיסמה: (מוצגת בהתקנה)
```

### בדיקת Logging
```bash
kubectl get pods -n logging
kubectl logs -n logging -l app=promtail
```

## 🚨 Troubleshooting

### בעיות נפוצות

1. **EKS לא נגיש**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name perion-cluster
   ```

2. **ArgoCD לא sync**
   ```bash
   kubectl get applications -n argocd
   argocd app sync hello-world-node --force
   ```

3. **ArgoCD לא נגיש**
   ```bash
   # בדוק שה-port-forward רץ
   kubectl port-forward svc/argocd-server -n argocd 8080:80
   # אם פורט 8080 תפוס, השתמש ב-8081
   kubectl port-forward svc/argocd-server -n argocd 8081:80
   ```

4. **HPA לא עובד**
   ```bash
   kubectl describe hpa hello-world-node-hpa
   kubectl top pods
   ```

## 📞 תמיכה

לשאלות או בעיות:
- פתח Issue ב-GitHub
- פנה למפתח הפרויקט

## 📄 רישיון

MIT License - ראה [LICENSE](LICENSE) לפרטים.

---

**נבנה עבור Perion DevOps Home Task** 🎯 