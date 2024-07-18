variable "openstack_domain" {
  type    = string
  default = env("OS_DOMAIN_NAME")
}

variable "openstack_username" {
  type    = string
  default = env("OS_USERNAME")
}

variable "openstack_password" {
  type    = string
  default = env("OS_PASSWORD")
}

variable "openstack_tenant" {
  type    = string
  default = env("OS_PROJECT_ID")
}

variable "identity_ep" {
   type    = string
   default = env("OS_AUTH_URL")
}

variable "region" {
  default = env("OS_REGION_NAME")
}

variable "image_name" {
  default = "Cloud Docker Ready"
}

packer {
  required_plugins {
    openstack = {
      version = ">= v1.1.0"
      source  = "github.com/hashicorp/openstack"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

source "openstack" "docker-ready" {
  availability_zone  = "ru-9a"
  domain_name        = var.openstack_domain
  username           = var.openstack_username
  password           = var.openstack_password
  tenant_name        = var.openstack_tenant
  identity_endpoint  = var.identity_ep
  floating_ip        = "654321-1234-4321-1234-12345678"
  source_image       = "Ubuntu 22.04 LTS 64-bit"
  image_name         = var.image_name

  flavor             = "SL1.2-4096"
  ssh_username       = "root"

  use_blockstorage_volume      = true
  volume_size                  = 16
  volume_type                  = "universal.ru-9a"
}

build {
  sources = ["source.openstack.docker-ready"]

  provisioner "shell" {
    script       = "docker-ready.sh"
    pause_before = "10s"
    timeout      = "10s"
  }

  # provisioner "ansible" {
  #   command                 = "ansible-playbook"
  #   extra_arguments         = ["--become", "--diff", "-vv"]
  #   inventory_file_template = templatefile("${path.root}/inventory.pkrtpl.hcl")
  #   playbook_file           = "main.yml"
  #   use_proxy               = false
  #   user                    = "root"
  # }
}
