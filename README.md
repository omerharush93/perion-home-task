# 🚀 Perion DevOps Home Task - Complete Solution

## 📋 Overview

A comprehensive DevOps project for the Perion home assignment, including infrastructure as code, application deployment on Kubernetes, CI/CD pipeline, and a performance solution.

## 🎯 Project Goals

### ✅ Task 1: Infrastructure as Code
- [x] **VPC** with public/private subnets in 2 AZs
- [x] **EKS cluster** with managed node groups
- [x] **ECR repository** with image scanning

### ✅ Task 2: Kubernetes Application Deployment
- [x] **Download app** from S3
- [x] **CI/CD pipeline** with GitHub Actions
- [x] **GitOps deployment** with ArgoCD
- [x] **Logging stack** with Loki + Grafana
- [x] **High Availability** with multi-AZ
- [x] **KEDA ScaledObject** with CPU(80%) + cron pre-scaling
- [x] **Cluster Autoscaler** for node management

## 🏗️ Architecture

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

## 🛠️ Technologies

| Component | Version | Role |
|------|------|-------|
| **Terraform** | 1.12.2+ | Infrastructure as Code |
| **AWS Provider** | 6.3.0+ | AWS resources management |
| **EKS** | 1.33 | Kubernetes cluster |
| **ArgoCD** | 8.1.3 | GitOps deployment |
| **Loki** | 6.31.0 | Log aggregation |
| **GitHub Actions** |  | CI/CD pipeline |
| **Helm** | 3.18.4 | Package Manager |

## 🚀 Installation & Usage

### Prerequisites

```bash
# Install required tools
./setup-requirements.md
```

### Step 1: Provision Infrastructure

```bash
cd terraform
chmod +x deploy.sh
./deploy.sh
```

### Step 2: Download the Application

```bash
chmod +x scripts/download-app.sh
./scripts/download-app.sh
```

### Step 3: Install ArgoCD

```bash
chmod +x argocd/install-argocd.sh
./argocd/install-argocd.sh
```

### Step 4: Install Logging Stack

```bash
chmod +x logging/install-loki.sh
./logging/install-loki.sh
```

### Step 5: Deploy the Application

```bash
helm upgrade --install hello-world-node ./helm/hello-world-node \
  --namespace default \
  --create-namespace
```

## 📊 Monitoring & Observability

### Logs
- **Loki + Promtail**: Collects and store logs
- **Grafana**: Visualization and analysis
- 

## ⚡ Performance Solution - 10:00 AM

### The Problem
Every morning at 10:00 AM, the application experiences a high load and does not scale up fast enough.

### The Solution
1. **Pre-scaling**: A CronJob runs at 9:00 AM and increases the deployment to 6 replicas
3. **HPA**: Fast scaling based on 80% CPU utilization
4. **Pod Anti-Affinity**: Distributes replicas across different nodes

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
    start: "45 9 * * *" # Every morning at 9:45 AM, pre-scale to 6 replicas
    end: "0 13 * * *"
    desiredReplicas: "6"
```

## 🔐 Security

### IAM & RBAC
- Principle of Least Privilege
- Service Accounts instead of IAM users

### Network Security
- Private subnets for EKS nodes
- Specific Security Groups
- Network Policies between pods

## 📈 High Availability

### Multi-AZ Deployment & High Availability
- Pod Anti-Affinity: Pods are not scheduled on the same node or the same AZ
- At least 3 replicas are always available
- Pod Disruption Budget (PDB)
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
1. **Build**: Build Docker image
2. **Test**: Run tests
3. **Push**: Push to ECR
4. **Deploy**: Update ArgoCD
5. **Verify**: Validate deployment

### ArgoCD Integration
- GitOps deployment
- Automated sync
- Rollback capabilities
- Health monitoring

## 🧪 Testing

### Infrastructure Testing
```bash
terraform plan
kubectl get nodes
kubectl cluster-info
```

### Application Testing
```bash
kubectl get pods -l app=hello-world-node
kubectl get svc hello-world-node-service
```

### ArgoCD Testing
```bash
kubectl get applications -n argocd
argocd app sync hello-world-node

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:80
# Open browser: http://localhost:8080
# User: admin, Password: (shown during install)
```

### Logging Testing
```bash
kubectl get pods -n logging
kubectl logs -n logging -l app=promtail
```

## 🚨 Troubleshooting

### Common Issues

1. **EKS not accessible**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name perion-cluster
   ```

2. **ArgoCD not syncing**
   ```bash
   kubectl get applications -n argocd
   argocd app sync hello-world-node --force
   ```

3. **ArgoCD not accessible**
   ```bash
   # Check if port-forward is running
   kubectl port-forward svc/argocd-server -n argocd 8080:80
   # If port 8080 is busy, use 8081
   kubectl port-forward svc/argocd-server -n argocd 8081:80
   ```

4. **HPA not working**
   ```bash
   kubectl describe hpa hello-world-node-hpa
   kubectl top pods
   ```

## 📞 Support

For questions or issues:
- Open an Issue on GitHub
- Contact the project maintainer

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Built for Perion DevOps Home Task** 🎯 