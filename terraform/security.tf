resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  version    = "v1.13.2"
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  depends_on = [
    opentelekomcloud_cce_cluster_v3.cluster
  ]
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  create_namespace = true
  version    = "0.25.0"
  
  depends_on = [
    opentelekomcloud_cce_cluster_v3.cluster
  ]
}

resource "helm_release" "trivy_operator" {
  name       = "trivy-operator"
  repository = "https://aquasecurity.github.io/helm-charts"
  chart      = "trivy-operator"
  namespace  = "trivy-system"
  create_namespace = true
  version    = "0.16.4"
  
  values = [<<EOF
    trivy:
      ignoreUnfixed: true
      severity: CRITICAL,HIGH
    operator:
      vulnerabilityReports:
        enabled: true
      configAuditReports:
        enabled: true
    EOF
  ]
  
  depends_on = [
    opentelekomcloud_cce_cluster_v3.cluster
  ]
}

resource "kubernetes_namespace" "llm_training" {
  metadata {
    name = "llm-training"
  }
  
  depends_on = [
    opentelekomcloud_cce_cluster_v3.cluster
  ]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
  depends_on = [opentelekomcloud_cce_cluster_v3.cluster]
}

resource "kubernetes_namespace" "bastion" {
  metadata {
    name = "bastion"
    labels = {
      name = "bastion"
    }
  }
  depends_on = [opentelekomcloud_cce_cluster_v3.cluster]
}

resource "kubernetes_network_policy" "llm_training_policy" {
  metadata {
    name      = "llm-training-network-policy"
    namespace = kubernetes_namespace.llm_training.metadata[0].name
  }

  spec {
    pod_selector {}
    
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }
    }
    
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "bastion"
          }
        }
      }
    }
    
    egress {}
    
    policy_types = ["Ingress", "Egress"]
  }
}