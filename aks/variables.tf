variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 2
}

variable "dns_prefix" {
    default = "js-interactive"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable cluster_name {
    default = "js-interactive-cluster"
}

variable resource_group_name {
    default = "js-interactive-2018"
}

variable location {
  default = "Central US"
}
