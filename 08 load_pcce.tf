resource "null_resource"  "configure_console" {
  

  provisioner "local-exec" {
    #description = "Create Admin user account"
    command = <<EOT
    curl -k -H 'Content-Type: application/json' -X POST -d '{"username": "${var.username}", "password": "${var.password}"}' https://${local.console_mgmt_ip}:8083/api/v1/signup
    EOT
  }  

  provisioner "local-exec" {
    #description = "Add license"
    command = <<EOT
    curl -k -u ${var.username}:${var.password} -H 'Content-Type: application/json' -X POST -d '{"key": "${var.license}"}' https://${local.console_mgmt_ip}:8083/api/v1/settings/license
    EOT
  }

  provisioner "local-exec" {
    #description = "Add Console IP to SAN"
    command = <<EOT
    curl -k -u ${var.username}:${var.password} -H 'Content-Type: application/json' -X POST -d '{"consoleSAN":["${local.console_mgmt_ip}","127.0.0.1","twistlock-console"]}' https://${local.console_mgmt_ip}:8083/api/v1/settings/certs
    EOT
  }

  provisioner "local-exec" {
    #description = "Download Twistcli"
    command = <<EOT
    [ -f ./twistcli ] && mv twistcli twistcli.old ; curl -L -k -u ${var.username}:${var.password} https://${local.console_mgmt_ip}:8083/api/v1/util/twistcli > twistcli; chmod +x twistcli
    EOT
  }

  provisioner "local-exec" {
    #description = "Install Defender deamonset into Kubernetes Cluster"
    command = <<EOT
    ./twistcli defender install kubernetes --namespace twistlock --monitor-service-accounts=true --user ${var.username} --password ${var.password} --address https://${local.console_mgmt_ip}:8083 --cluster-address ${local.console_mgmt_ip}
    EOT
  }

  depends_on = [kubernetes_deployment.twistlock_console]
}



