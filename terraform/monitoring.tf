resource "helm_release" "prometheus_operator" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true
  version    = "51.4.0"
  
  values = [
    file("${path.module}/../monitoring/prometheus-values.yaml")
  ]
  
  depends_on = [
    opentelekomcloud_cce_cluster_v3.cluster,
    opentelekomcloud_cce_node_v3.standard_nodes,
    opentelekomcloud_cce_node_v3.gpu_nodes
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  create_namespace = true
  version    = "6.58.7"
  
  values = [
    file("${path.module}/../monitoring/grafana-values.yaml")
  ]
  
  depends_on = [
    helm_release.prometheus_operator
  ]
}

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "kubernetes-cluster.json" = file("${path.module}/../monitoring/dashboards/kubernetes-cluster.json")
    "llm-training.json"      = file("${path.module}/../monitoring/dashboards/llm-training.json")
  }
  
  depends_on = [
    helm_release.grafana
  ]
}

resource "helm_release" "node_exporter" {
  name       = "node-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  namespace  = "monitoring"
  create_namespace = true
  version    = "4.23.2"
  
  depends_on = [
    helm_release.prometheus_operator
  ]
}

resource "helm_release" "dcgm_exporter" {
  name       = "dcgm-exporter"
  repository = "https://nvidia.github.io/dcgm-exporter/helm-charts"
  chart      = "dcgm-exporter"
  namespace  = "monitoring"
  create_namespace = true
  version    = "3.1.5"
  
  set {
    name  = "nodeSelector.accelerator"
    value = "nvidia"
  }
  
  depends_on = [
    helm_release.prometheus_operator,
    opentelekomcloud_cce_node_v3.gpu_nodes
  ]
}