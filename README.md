# 🚀 Perion DevOps Home Task - Complete Solution

## 📋 Overview

This repository contains a complete DevOps home assignment for Perion, including infrastructure as code, CI/CD, Kubernetes deployment, and logging on AWS EKS.

For a full breakdown of the project layout and folder purposes, refer to [docs/project-structure.md](./docs/project-structure.md).

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

The complete system architecture, including all main AWS, Kubernetes, CI/CD, and logging components, is illustrated in the following diagram:  
[**View the architecture diagram on Eraser**](https://app.eraser.io/workspace/hyTbJCpDKabCoJmpLUr2?origin=share)

## 🛠️ Technologies

| Component         | Version  | Role & Description                                      |
|------------------|----------|--------------------------------------------------------|
| **Terraform**    | 1.12.2+  | Infrastructure as Code for AWS resources                |
| **AWS Provider** | 6.3.0+   | AWS resource management for Terraform                   |
| **EKS**          | 1.33     | Managed Kubernetes cluster on AWS                       |
| **ArgoCD**       | 8.1.3    | GitOps deployment and continuous delivery               |
| **Loki**         | 6.31.0   | Log aggregation and storage                             |
| **Promtail**     | latest   | Log shipping from pods to Loki                          |
| **Grafana**      | latest   | Log visualization and dashboarding                      |
| **KEDA**         | latest   | Advanced event-driven and scheduled autoscaling         |
| **metrics-server**| latest  | Resource metrics for HPA/KEDA                          |
| **GitHub Actions**|         | CI/CD pipeline for build, test, and deploy              |
| **Helm**         | 3.18.4   | Kubernetes package manager (charts)                     |

## 📁 Project Structure

For a detailed explanation of the folder and file organization, see [docs/project-structure.md](./docs/project-structure.md).

## 🚀 Installation & Usage

> **Note:** All setup and utility scripts are located in the `scripts/` directory.

### Prerequisites

Install all required tools for infrastructure, Kubernetes, and CI/CD:
```bash
./docs/setup-requirements.md
```

### Connect to the EKS Cluster
Before running any `kubectl` commands, make sure you are connected to the EKS cluster:
```bash
aws eks update-kubeconfig --region us-east-1 --name omer-perion-cluster
```

### Step 1: Provision Infrastructure
This script provisions the AWS infrastructure (VPC, EKS, IAM, ECR) using Terraform.
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### Step 2: Download the Application
This script downloads and extracts the Node.js application from S3, and initializes a local Git repository.
```bash
chmod +x scripts/download-app.sh
./scripts/download-app.sh
```

### Step 3: Install ArgoCD
This script installs ArgoCD in the cluster and configures the application for GitOps deployment.
```bash
chmod +x scripts/install-argocd.sh
./scripts/install-argocd.sh
```

### Step 4: Install Logging Stack
This script installs Loki, Promtail, and Grafana for centralized logging and visualization.
```bash
chmod +x scripts/install-loki.sh
./scripts/install-loki.sh
```

### Step 5: Install metrics-server (for HPA/KEDA CPU autoscaling)
This script installs metrics-server in the `kube-system` namespace, required for HPA and KEDA CPU-based scaling.
```bash
chmod +x scripts/install-metrics-server.sh
./scripts/install-metrics-server.sh
```

### Step 6: Install KEDA (for advanced autoscaling)
This script installs KEDA in the `keda` namespace for event-driven and scheduled autoscaling.
```bash
chmod +x scripts/install-keda.sh
./scripts/install-keda.sh
```

### Step 7: Deploy the Application
> **Note:** By default, the application is deployed automatically by ArgoCD (GitOps).
> If you want to deploy manually (for local development or testing), use the following Helm command:
```bash
helm upgrade --install hello-world-node ./helm/hello-world-node \
  --namespace default \
  --create-namespace
```
- This command deploys the Node.js Hello World application to the cluster using Helm.

### Step 8: Validate the Application Deployment
After deploying the application (either via ArgoCD or Helm), you can validate the deployment using the provided script:
```bash
chmod +x scripts/validate-helm-deployment.sh
./scripts/validate-helm-deployment.sh
```
- This script checks the status of the deployment, service, and readiness of the application in the cluster.

## 📊 Monitoring & Observability

### Logging Stack (Installed via `scripts/install-loki.sh`)
- **Loki**: Aggregates logs from all pods.
- **Promtail**: Collects and ships logs to Loki.
- **Grafana**: Visualizes logs from Loki.
  - Exposed as a LoadBalancer (external URL if available).
  - Default credentials: **admin** / **admin123**
  - If no external URL, use: `kubectl port-forward svc/grafana -n logging 3000:80`
- Promtail is pre-configured to collect logs from the Node.js app.

### GitOps & Continuous Delivery (Installed via `scripts/install-argocd.sh`)
- **ArgoCD**: GitOps deployment tool, installed in the `argocd` namespace.
  - Version: 8.1.3
  - Authentication disabled for demo/dev.
  - UI: `kubectl port-forward svc/argocd-server -n argocd 8080:80`
  - Application auto-configured if `hello-world-app.yaml` exists.

### Autoscaling & Metrics
- **metrics-server**: Provides resource metrics (CPU/memory) for HPA and KEDA. Installed in the `kube-system` namespace.
- **KEDA**: Advanced event-driven and scheduled autoscaling. Installed in the `keda` namespace. Enables scaling based on CPU, cron, and other triggers.

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
For best practices and operational standards, see [docs/best-practices.md](./docs/best-practices.md).

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

## 🔗 Useful Links

### Grafana Dashboard
- Direct URL: [http://aef6637b788c04b40a1f40454ab0adf6-1475231150.us-east-1.elb.amazonaws.com/](http://aef6637b788c04b40a1f40454ab0adf6-1475231150.us-east-1.elb.amazonaws.com/)
- (If using port-forward: `kubectl port-forward svc/grafana -n logging 3000:80`)
- Open in browser: [http://localhost:3000](http://localhost:3000)
- Default credentials: **Username:** admin  **Password:** admin123

### ArgoCD UI
- Port-forward: `kubectl port-forward svc/argocd-server -n argocd 8080:80`
- Open in browser: [http://localhost:8080](http://localhost:8080)
- Default credentials: **Username:** admin  **Password:** (see install output) 
