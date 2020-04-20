output "Voting_APP-ip" {
    value = kubernetes_service.voting_service.load_balancer_ingress[0].ip
}

output "Voting_Result-ip" {
    value = kubernetes_service.result_service.load_balancer_ingress[0].ip
}


locals {
    console_mgmt_ip = kubernetes_service.twistlock_console.load_balancer_ingress[0].ip
}

output "PCC_Console-IP" {
    value = "${local.console_mgmt_ip}"
}

output "PCC_Conslole-Username" {
    value = var.username
}
output "PCC_Conslole-Password" {
    value = var.password
}