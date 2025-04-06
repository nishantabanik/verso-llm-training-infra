terraform {
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "~> 1.35.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "opentelekomcloud" {
  domain_name = var.otc_domain_name
  tenant_name = var.otc_project_name
  username    = var.otc_username
  password    = var.otc_password
  auth_url    = var.otc_auth_url
  region      = var.otc_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}