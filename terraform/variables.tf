variable "otc_domain_name" {
  description = "OTC domain name"
  type        = string
}

variable "otc_project_name" {
  description = "OTC project name"
  type        = string
}

variable "otc_username" {
  description = "OTC username"
  type        = string
}

variable "otc_password" {
  description = "OTC password"
  type        = string
  sensitive   = true
}

variable "otc_auth_url" {
  description = "OTC authentication URL"
  type        = string
  default     = "https://iam.eu-de.otc.t-systems.com/v3"
}

variable "otc_region" {
  description = "OTC region"
  type        = string
  default     = "eu-de"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "llm-training-cluster"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-de-01", "eu-de-02", "eu-de-03"]
}

variable "node_flavor" {
  description = "Flavor of the worker nodes"
  type        = string
  default     = "s2.2xlarge.8"
}

variable "gpu_node_flavor" {
  description = "Flavor of the GPU worker nodes"
  type        = string
  default     = "p2v.8xlarge.8" # GPU-enabled instance for ML workloads
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "gpu_node_count" {
  description = "Number of GPU worker nodes"
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "admin_cidr" {
  description = "CIDR block for admin access"
  type        = string
  default     = "10.0.0.0/8" # Modify to our private IP range
}