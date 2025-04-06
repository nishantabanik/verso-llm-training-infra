# LLM Training Infrastructure

This repository contains the infrastructure code to set up a Kubernetes cluster for training large language models (LLMs) in the Open Telekom Cloud.

## Architecture

The solution includes:

1. Kubernetes cluster provisioned with Terraform in OTC
2. GPU-enabled nodes for LLM training
3. Monitoring stack (Prometheus, Grafana, node/GPU exporters)
4. Helm chart for deploying LLM training workloads
5. Security scanning and enforcement
6. Private access through bastion host

## Prerequisites

- OTC account credentials
- Terraform 1.0+
- Kubectl
- Helm 3
- SSH key pair

## Deployment Instructions

### 1. Configure OTC credentials

Create a `.env` file with your credentials:

```bash
export TF_VAR_otc_domain_name="our_domain_name"
export TF_VAR_otc_project_name="our_project_name"
export TF_VAR_otc_username="our_username"
export TF_VAR_otc_password="our_password"
```

Source the file to set the environment variables:

```bash
source .env
```

### 2. Deploy Infrastructure

Navigate to the `terraform` directory and deploy the infrastructure:

```bash
cd terraform
terraform init
terraform apply
```

### 3. Configure kubectl

After deployment, configure `kubectl` using the bastion host. First, SSH into the bastion:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw bastion_public_ip)
```

Then, on the bastion host, retrieve the kubeconfig:

```bash
otc cce cluster kubeconfig show --cluster-name llm-training-cluster > ~/.kube/config
```

### 4. Deploy LLM Training Workload

Deploy the LLM training workload using Helm:

```bash
helm install llm-training ./helm/llm-training -n llm-training --create-namespace
```

### 5. Access Monitoring

Access Grafana through the bastion host using port forwarding. In one terminal, set up port forwarding in the cluster:

```bash
kubectl -n monitoring port-forward svc/grafana 3000:80
```

In another terminal, establish an SSH tunnel:

```bash
ssh -i ~/.ssh/id_rsa -L 3000:localhost:3000 ubuntu@$(terraform output -raw bastion_public_ip)
```

Open your browser and access Grafana at `http://localhost:3000`.

## Maintenance Process

Regular maintenance tasks include:

- **Kubernetes version upgrades**: Quarterly
- **Node OS updates**: Monthly
- **Application updates**: As needed
- **Security scanning**: Weekly

## Security

The architecture implements the following security measures:

- Private Kubernetes API endpoint (not publicly accessible)
- Access restricted to bastion host only
- Container image scanning with Trivy
- Network policies to restrict pod communication
- Pod security enforcement

## Answers to Questions

### Which components do you need?

For setting up a Kubernetes cluster to train LLMs in OTC, we need:

1. **OTC Infrastructure**:

   - VPC and subnet
   - Security groups
   - CCE Kubernetes cluster
   - Regular worker nodes for system components
   - GPU-enabled worker nodes for LLM training
   - Bastion host for private access

2. **Kubernetes Components**:

   - Container runtime (default with CCE)
   - GPU drivers and device plugins
   - Storage classes for persistent data

3. **Application Components**:

   - Helm chart for LLM training deployment
   - Storage for large model data
   - Container registry access

4. **Monitoring Components**:

   - Prometheus for metrics collection
   - Grafana for visualization
   - Node and GPU exporters
   - Custom dashboards

5. **Security Components**:
   - Trivy for vulnerability scanning
   - Network policies
   - Pod security admission controllers

### How would you provide a monitoring solution for the cluster?

In our solution monitoring stack consists of (there are other tools/methods to implement observability, also I didn't add Loki or Elasticsearch in this solution which can make it a little more complex):

- Prometheus for metrics collection
- Grafana for visualization
- Node exporter for system metrics
- DCGM exporter for GPU metrics
- Custom dashboards for cluster and LLM training metrics
- Alerting rules for critical conditions

### How can the cluster be accessed without having it publicly available?

The cluster can be accessed privately through:

- A bastion host with a public IP
- VPN connection to the private network
- SSH port forwarding for accessing cluster services
- Network security groups limiting access to admin IPs

### How do we make sure that no vulnerabilities are present?

Vulnerability prevention is implemented with (there are a few other solutions which also could be applied):

- Trivy-operator for continuous image scanning
- Admission controllers rejecting vulnerable images
- Regular scans using the trivy-scan.sh script
- Security updates automation
- Network policies restricting pod communication

### Which components need to be maintained and updated?

Components requiring maintenance:

- Kubernetes cluster version (quarterly)
- Node OS and software updates (monthly or quarterly)
- Container images and dependencies (continuous)
- Monitoring stack (as needed)
- Security tools and policies (monthly)

The maintenance process is automated through:

- CI/CD pipelines for infrastructure updates
- Trivy scans in the CI pipeline
- Regular security updates
- Centralized logging for audit
