# Project Folder Structure - Perion DevOps Project

```
Perion_Home_Task/
├── app/
│   └── hello-world-node/
│       ├── Dockerfile
│       ├── Dockerfile-tests
│       ├── package.json
│       ├── process.json
│       ├── README.md
│       ├── server.js
│       └── tests/
│           └── testmyapp.js
├── argocd/
│   ├── hello-world-app.yaml
│   └── serviceaccount.yaml
├── charts/
│   └── hello-world-node/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── keda-scaler.yaml
│           └── service.yaml
├── docs/
│   ├── architecture.png
│   ├── best-practices.md
│   ├── project-structure.md
│   └── setup-requirements.md
├── logging/
│   └── values.yaml
├── scripts/
│   ├── deploy.sh
│   ├── download-app.sh
│   ├── install-argocd.sh
│   ├── install-keda.sh
│   ├── install-loki.sh
│   ├── install-metrics-server.sh
│   └── validate-helm-deployment.sh
├── terraform/
│   ├── addons.tf
│   ├── cluster-autoscaler-values.yaml
│   ├── cluster-autoscaler.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── variables.tf
├── README.md
```

## Folder Explanations:

### app/hello-world-node/
- **Purpose**: Node.js application source code, configuration files, Docker build files, and tests.
- **Relevant to**: Application logic, Docker image, and automated testing.

### argocd/
- **Purpose**: ArgoCD configuration files for automated GitOps deployment.
- **Relevant to**: Continuous deployment and GitOps workflows.

### charts/hello-world-node/
- **Purpose**: Helm chart for deploying the Node.js application, including templates for deployment, service, and KEDA scaler.
- **Relevant to**: Kubernetes deployment, scaling, and service exposure.

### docs/
- **Purpose**: Project documentation, best practices, architecture diagram, and setup requirements.
- **Relevant to**: Onboarding, architecture, and operational guides.

### logging/
- **Purpose**: Logging stack configuration (e.g., Loki values).
- **Relevant to**: Log collection, visualization, and troubleshooting.

### scripts/
- **Purpose**: Utility scripts for deployment, installation of components (ArgoCD, KEDA, Loki, metrics-server), and validation.
- **Relevant to**: Automation, setup, and maintenance tasks.

### terraform/
- **Purpose**: Infrastructure as Code for AWS resources (VPC, EKS, IAM, ECR, autoscaler, etc.), including configuration, variables, outputs, and providers.
- **Relevant to**: Infrastructure provisioning, management, and scaling.

### README.md
- **Purpose**: Main project documentation and usage instructions.
- **Relevant to**: General project overview and getting started.

## Structure Benefits:
1. **Separation of Concerns**: Each folder handles a specific domain.
2. **Maintainability**: Easy to find and update files.
3. **Scalability**: Easy to add new components.
4. **Security**: Sensitive code/configs are separated.
5. **Documentation**: Clear documentation for each part of the project. 