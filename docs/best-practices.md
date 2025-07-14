# Best Practices - Perion DevOps Project

## 🔐 Security Best Practices

### 1. IAM Roles & Permissions
- **Principle of Least Privilege**: כל משתמש/שירות מקבל רק הרשאות מינימליות נדרשות
- **Service Accounts**: שימוש ב-Kubernetes Service Accounts במקום IAM users
- **Role-Based Access Control (RBAC)**: הגדרת roles ספציפיים לכל namespace

### 2. Network Security
- **Network Policies**: הגבלת תעבורת רשת בין pods
- **Private Subnets**: EKS nodes רק ב-private subnets
- **Security Groups**: הגדרת security groups ספציפיים לכל רכיב

### 3. Secrets Management
```yaml
# שימוש ב-Kubernetes Secrets במקום environment variables
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  database-url: <base64-encoded>
  api-key: <base64-encoded>
```

## 🏷️ Tagging Strategy

### AWS Resources
```hcl
default_tags {
  tags = {
    Project     = "perion-home-task"
    Environment = "dev"
    Owner       = "omer"
    ManagedBy   = "terraform"
    CostCenter  = "devops"
  }
}
```

### Kubernetes Resources
```yaml
metadata:
  labels:
    app: hello-world-node
    version: v1
    environment: dev
    owner: omer
```

## 📊 Monitoring & Observability

### 1. Health Checks
- **Liveness Probe**: בדיקה שהאפליקציה עובדת
- **Readiness Probe**: בדיקה שהאפליקציה מוכנה לקבל traffic
- **Startup Probe**: בדיקה בזמן startup

### 2. Metrics Collection
- **Prometheus**: איסוף metrics
- **Grafana**: visualization
- **Loki**: log aggregation

### 3. Alerting
```yaml
# Prometheus Alert Rules
groups:
- name: app-alerts
  rules:
  - alert: HighCPUUsage
    expr: container_cpu_usage_seconds_total > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
```

## 🔄 High Availability (HA)

### 1. Multi-AZ Deployment
- **Pod Anti-Affinity**: pods לא על אותו node
- **Node Affinity**: pods על nodes מתאימים
- **Replica Distribution**: לפחות 3 replicas

### 2. Rolling Updates
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### 3. Pod Disruption Budget
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
spec:
  minAvailable: 2
```

## ⚡ Performance Optimization

### 1. Resource Management
- **Resource Requests/Limits**: הגדרת משאבים מתאימים
- **Vertical Pod Autoscaler**: אופטימיזציה אוטומטית של משאבים
- **Horizontal Pod Autoscaler**: סקיילינג אופקי לפי עומס

### 2. Pre-scaling Strategy
- **CronJob**: פריסה מוקדמת לפני עומס צפוי
- **Predictive Scaling**: שימוש ב-machine learning לניבוי עומס
- **Scheduled Scaling**: סקיילינג לפי לוח זמנים

### 3. Caching
- **Redis**: caching עבור נתונים דינמיים
- **CDN**: caching עבור static content
- **Application Caching**: in-memory caching

## 🔧 CI/CD Best Practices

### 1. Pipeline Security
- **Secrets Management**: שימוש ב-GitHub Secrets
- **Image Scanning**: סריקת Docker images
- **Dependency Scanning**: סריקת dependencies

### 2. Deployment Strategy
- **Blue-Green**: zero-downtime deployments
- **Canary**: gradual rollout
- **Rollback Strategy**: יכולת חזרה לגרסה קודמת

### 3. Testing
- **Unit Tests**: בדיקות יחידה
- **Integration Tests**: בדיקות אינטגרציה
- **Load Tests**: בדיקות עומס

## 📝 Documentation

### 1. Code Documentation
- **README.md**: תיאור הפרויקט
- **API Documentation**: תיעוד API
- **Architecture Diagrams**: דיאגרמות ארכיטקטורה

### 2. Runbooks
- **Deployment Procedures**: נהלי פריסה
- **Troubleshooting Guides**: מדריכי פתרון בעיות
- **Emergency Procedures**: נהלי חירום

## 🚀 Disaster Recovery

### 1. Backup Strategy
- **Database Backups**: גיבוי מסד נתונים
- **Configuration Backups**: גיבוי קונפיגורציה
- **State Backups**: גיבוי Terraform state

### 2. Recovery Procedures
- **RTO (Recovery Time Objective)**: זמן התאוששות מקסימלי
- **RPO (Recovery Point Objective)**: אובדן נתונים מקסימלי
- **Testing**: בדיקת נהלי התאוששות 