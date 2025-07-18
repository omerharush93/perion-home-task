# Recommended Folder Structure - Perion DevOps Project

```
perion-home-task/
├── terraform/                  # Infrastructure as Code (VPC, EKS, IAM, ECR)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── deploy.sh
│   └── ...
│
├── charts/hello-world-node/    # Helm Chart for Node.js app
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── keda-scaler.yaml
│
├── argocd/                     # ArgoCD Configuration
│   ├── install-argocd.sh
│   ├── hello-world-app.yaml
│   └── serviceaccount.yaml
│
├── logging/                    # Logging Stack
│   ├── install-loki.sh
│   ├── values.yaml
│   └── ...
│
├── app/hello-world-node/       # Application code (Node.js)
│   ├── server.js
│   ├── package.json
│   ├── Dockerfile
│   └── tests/
│
├── scripts/                    # Utility scripts
│   ├── download-app.sh
│   └── ...
│
├── docs/                       # Documentation
│   ├── README.md
│   ├── best-practices.md
│   ├── setup-requirements.md
│   └── project-structure.md
│
├── .github/workflows/          # GitHub Actions workflows
│   └── ...
│
├── README.md                   # Main project documentation
└── ...
```

## Folder Explanations:

### terraform/
- **Purpose**: Infrastructure as Code for AWS (VPC, EKS, IAM, ECR)
- **Relevant to**: Task 1 - Infrastructure as Code

### charts/hello-world-node/
- **Purpose**: Helm chart for deploying the Node.js application
- **Relevant to**: Kubernetes deployment, scaling, and service exposure

### argocd/
- **Purpose**: GitOps deployment and ArgoCD configuration
- **Relevant to**: Automated application deployment and sync

### logging/
- **Purpose**: Centralized logging stack (Loki, Promtail, Grafana)
- **Relevant to**: Log collection, visualization, and troubleshooting

### app/hello-world-node/
- **Purpose**: Node.js application source code and Docker build
- **Relevant to**: Application logic, Docker image, and tests

### scripts/
- **Purpose**: Utility scripts for setup and automation
- **Relevant to**: Downloading app from S3, setup helpers

### docs/
- **Purpose**: Project documentation and best practices
- **Relevant to**: Onboarding, architecture, and operational guides

### .github/workflows/
- **Purpose**: CI/CD pipeline definitions (GitHub Actions)
- **Relevant to**: Automated build, test, and deploy

### README.md
- **Purpose**: Main project documentation and instructions

## Structure Benefits:
1. **Separation of Concerns**: Each folder handles a specific domain
2. **Maintainability**: Easy to find and update files
3. **Scalability**: Easy to add new components
4. **Security**: Sensitive code/configs are separated
5. **Documentation**: Clear documentation for each part 