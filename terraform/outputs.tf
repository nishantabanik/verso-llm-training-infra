output "cluster_id" {
  description = "ID of the created Kubernetes cluster"
  value       = opentelekomcloud_cce_cluster_v3.cluster.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = opentelekomcloud_vpc_eip_v1.bastion_eip.publicip[0].ip_address
}

output "kubeconfig_command" {
  description = "Command to get the kubeconfig file"
  value       = "otc cce cluster kubeconfig show --cluster-name ${var.cluster_name} > ~/.kube/config"
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = "kubectl get secret --namespace monitoring grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
  sensitive   = true
}