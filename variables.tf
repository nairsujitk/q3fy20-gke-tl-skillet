variable "cluster_name" {
  default = "skn-pcc-demo-gke"
}

variable "region" {
  default = ""
}

variable "region_zone" {
  default = ""
}

variable "project_name" {
  description = "ID of the GCP project"
  default     = ""
}

variable "gcp_credential" {
  description = "Copy GCP .jason file data into terraform.tfvars file"
}

variable "password" {
  description = "Password for GKE cluster & PCC Console"
  default     = "Sknpcceadmin@123"
}

variable "username" {
  description = "Username for GKE cluster & PCC Console"
  default     = "sknadmin"
}

variable "license" {
  description = "Twistlock license"
  default     = ""
}

variable "authcode" {
  description = "Twistlock Authcode"
  default     = ""
}

variable "console_service_type"{
  default = "LoadBalancer"
} 
