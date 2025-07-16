# Prerequisites for Perion DevOps Project

## Required Tools and Explanations:

### 1. Terraform CLI >= 1.12.2
**Why needed:** Manage infrastructure as code (IaC) for VPC, EKS, IAM roles, ECR
```bash
# macOS with Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Or direct download (Linux)
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs)"
sudo apt-get update && sudo apt-get install terraform
```

### 2. AWS CLI v2
**Why needed:** Interact with AWS services (ECR, S3, EKS)
```bash
# macOS
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 3. kubectl
**Why needed:** Manage Kubernetes cluster and deployments
```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 4. Docker
**Why needed:** Build container images for CI/CD pipeline
```bash
# macOS
brew install --cask docker

# Linux
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 5. Git
**Why needed:** Manage code and configuration
```bash
# macOS
brew install git

# Linux
sudo apt-get install git
```

### 6. Helm
**Why needed:** Install ArgoCD and logging stack (Loki, Promtail, Grafana)
```bash
# macOS
brew install helm

# Linux
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## Configure AWS Credentials:
```bash
aws configure
# Enter: AWS Access Key ID, Secret Access Key, Default region (us-east-1), Default output format (json)
```

## Verify Installations:
```bash
terraform --version
aws --version
kubectl version --client
docker --version
git --version
helm version
``` 