output "web_vm_ip" {
  value = docker_container.web_vm.networks_advanced[0].ipv4_address
}

output "db_vm_ip" {
  value = docker_container.db_vm.networks_advanced[0].ipv4_address
}

output "semaphore_webhooks" {
  description = "Webhook URLs for Semaphore integration"
  value = {
    deployment_complete   = "http://localhost:3000/api/webhooks/deployment/${var.semaphore_project_id}"
    infrastructure_ready  = "http://localhost:3000/api/webhooks/infrastructure/${var.semaphore_project_id}"
  }
}