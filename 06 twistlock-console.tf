resource "kubernetes_namespace" "twistlock" {
  metadata {
    name = "twistlock"
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_config_map" "twistlock_console" {
  metadata {
    name      = "twistlock-console"
    namespace = "twistlock"
  }

  data = {
    "twistlock.cfg" = "${chomp("#  _____          _     _   _            _    \n# |_   _|_      _(_)___| |_| | ___   ___| | __  \n#   | | \\ \\ /\\ / / / __| __| |/ _ \\ / __| |/ /      \n#   | |  \\ V  V /| \\__ \\ |_| | (_) | (__|   <       \n#   |_|   \\_/\\_/ |_|___/\\__|_|\\___/ \\___|_|\\_\\\\     \n\n# This configuration file contains the setup parameters for Twistlock\n# This file is typically stored in the same directory as the installation script (twistlock.sh)\n# To reconfigure settings, update this configuration file and re-run twistlock.sh; state and unchanged settings will persist\n\n\n\n#############################################\n#     Network configuration\n#############################################\n# Each port must be set to a unique value (multiple services cannot share the same port)\n###### Management Console ports #####\n# Sets the ports that the Twistlock management website listens on\n# The system that you use to configure Twistlock must be able to connect to the Twistlock Console on these ports\n# To disable the HTTP listener, leave the value empty (e.g. MANAGEMENT_PORT_HTTP=)\nMANAGEMENT_PORT_HTTP=$${MANAGEMENT_PORT_HTTP-8081}\nMANAGEMENT_PORT_HTTPS=8083\n\n##### Inter-system communication port ##### \n# Sets the port for communication between the Defender(s) and the Console\nCOMMUNICATION_PORT=8084\n\n##### Certificate common names (optional) #####\n# Determines how to construct the CN in the Console's certificate\n# This value should not be modified unless instructed to by Twistlock Support\nCONSOLE_CN=$(hostname --fqdn 2>/dev/null); if [[ $? == 1 ]]; then CONSOLE_CN=$(hostname); fi\n# Determines how to construct the CN in the Defenders' certificates\n# Each Defender authenticates to the Console with this certificate and each cert must have a unique CN\n# These values should not be modified unless instructed to by Twistlock Support\nDEFENDER_CN=$${DEFENDER_CN:-}\n\n#############################################\n#     Twistlock system configuration\n#############################################\n###### Data recovery #####\n# Data recovery automatically exports the full Twistlock configuration to the specified path every 24 hours\n# Daily, weekly, and monthly snapshots are retained\n# The exported configuration can be stored on durable storage or backed up remotely with other tools\n# Sets data recovery state (enabled or disabled)\nDATA_RECOVERY_ENABLED=true\n# Sets the directory to which Twistlock data is exported\nDATA_RECOVERY_VOLUME=/var/lib/twistlock-backup\n\n##### Read only containers #####\n# Sets Twistlock containers' file-systems to read-only\nREAD_ONLY_FS=true\n\n##### Storage paths #####\n# Sets the base directory to store Twistlock local data (db and log files)\nDATA_FOLDER=/var/lib/twistlock\n\n##### Docker socket #####\n# Sets the location of the Docker socket file\nDOCKER_SOCKET=$${DOCKER_SOCKET:-/var/run/docker.sock}\n# Sets the type of the Docker listener (TCP or NONE)\nDEFENDER_LISTENER_TYPE=$${DEFENDER_LISTENER_TYPE:-NONE}\n\n#### SCAP (XCCDF) configuration ####\n# Sets SCAP state (enabled or disabled)\nSCAP_ENABLED=$${SCAP_ENABLED:-false}\n\n#### systemd configuration ####\n# Installs Twistlock as systemd service\nSYSTEMD_ENABLED=$${SYSTEMD_ENABLED:-false}\n\n#### userid configuration ####\n# Run Twistlock Console processes as root (default, twistlock user account)\n# Typically used to run Console on standard (tcp/443) privileged port for TLS\nRUN_CONSOLE_AS_ROOT=$${RUN_CONSOLE_AS_ROOT:-false}\n\n#### SELinux configuration ####\n# If SELinux is enabled in dockerd, enable running Twistlock Console and Defender with a dedicated SELinux label\n# See https://docs.docker.com/engine/reference/run/#security-configuration\nSELINUX_LABEL=disable\n\n#############################################\n#      High availability settings\n#############################################\n# Only to be used when the Console is deployed outside of a Kubernetes cluster\n# This native HA capability uses Mongo clustering and requires 3 or more instances\nHIGH_AVAILABILITY_ENABLED=false\nHIGH_AVAILABILITY_STATE=PRIMARY\nHIGH_AVAILABILITY_PORT=8086\n\n\n\n#############################################\n#      Twistlock repository configuration\n#############################################\n# Sets the version tag of the Twistlock containers\n# Do not modify unless instructed to by Twistlock Support\nDOCKER_TWISTLOCK_TAG=_19_11_506\n")}"
  }
  depends_on = [kubernetes_namespace.twistlock]
}


resource "kubernetes_service" "twistlock_console" {
  metadata {
    name      = "twistlock-console"
    namespace = "twistlock"

    labels = {
      name = "console"
    }
  }

  spec {
    port {
      name = "communication-port"
      port = 8084
    }

    port {
      name = "management-port-https"
      port = 8083
    }

    port {
      name = "mgmt-http"
      port = 8081
    }

    selector = {
      name = "twistlock-console"
    }

    type = var.console_service_type
  }
  depends_on = [kubernetes_namespace.twistlock]
}

resource "kubernetes_service_account" "twistlock_console" {
  metadata {
    name      = "twistlock-console"
    namespace = "twistlock"
  }
  depends_on = [kubernetes_namespace.twistlock]
}


resource "kubernetes_persistent_volume_claim" "twistlock_console" {
  metadata {
    name      = "twistlock-console"
    namespace = "twistlock"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }
  depends_on = [kubernetes_namespace.twistlock]
}

resource "kubernetes_deployment" "twistlock_console" {
  metadata {
    name      = "twistlock-console"
    namespace = "twistlock"

    labels = {
      name = "twistlock-console"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "twistlock-console"
      }
    }

    template {
      metadata {
        name      = "twistlock-console"
        namespace = "twistlock"

        labels = {
          name = "twistlock-console"
        }
      }

      spec {
        volume {
          name = "console-persistent-volume"

          persistent_volume_claim {
            claim_name = "twistlock-console"
          }
        }

        volume {
          name = "twistlock-config-volume"

          config_map {
            name = "twistlock-console"
          }
        }

        volume {
          name = "syslog-socket"

          host_path {
            path = "/dev/log"
          }
        }

        container {
          name  = "twistlock-console"
          image = "registry-auth.twistlock.com/${var.authcode}/twistlock/console:console_19_11_506"

          port {
            name           = "mgmt-https"
            container_port = 8083
          }

          port {
            name           = "communication"
            container_port = 8084
          }

          port {
            name           = "mgmt-http"
            container_port = 8081
          }

          env {
            name  = "HIGH_AVAILABILITY_ENABLED"
            value = "false"
          }

          env {
            name  = "CONFIG_PATH"
            value = "/data/config/twistlock.cfg"
          }

          env {
            name  = "LOG_PROD"
            value = "true"
          }

          env {
            name  = "DATA_RECOVERY_ENABLED"
            value = "true"
          }

          env {
            name  = "COMMUNICATION_PORT"
            value = "8084"
          }

          env {
            name  = "MANAGEMENT_PORT_HTTPS"
            value = "8083"
          }

          env {
            name  = "MANAGEMENT_PORT_HTTP"
            value = "8081"
          }

          volume_mount {
            name       = "twistlock-config-volume"
            mount_path = "/data/config/"
          }

          volume_mount {
            name       = "console-persistent-volume"
            mount_path = "/var/lib/twistlock"
            sub_path   = "var/lib/twistlock"
          }

          volume_mount {
            name       = "console-persistent-volume"
            mount_path = "/var/lib/twistlock-backup"
            sub_path   = "var/lib/twistlock-backup"
          }

          volume_mount {
            name       = "syslog-socket"
            mount_path = "/dev/log"
          }

          security_context {
            read_only_root_filesystem = true
          }
        }

        restart_policy       = "Always"
        service_account_name = "twistlock-console"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
  depends_on = [kubernetes_namespace.twistlock]
}
