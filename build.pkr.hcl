packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    scaleway = {
      version = ">= 1.0.5"
      source  = "github.com/scaleway/scaleway"
    }
  }
}

variable "debian_iso_checksum" {
  type    = string
}

variable "debian_iso_url" {
  type    = string
}

variable "debian_preseed_file" {
  type    = string
}

variable "hostname" {
  type    = string
}

variable "output_dir" {
  type    = string
}

variable "image_name" {
  type    = string
}

variable "scaleway_id" {
  type    = string
}

variable "scaleway_commercial_type" {
  type    = string
}

variable "scaleway_default_zone" {
  type    = string
}

variable "ssh_private_key_file" {
  type    = string
}

locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
}

source "qemu" "debian" {
  accelerator      = "kvm"
  boot_command     = ["<esc>", "<esc><wait>", "install ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.debian_preseed_file} ", "debian-installer=en_US ", "auto ", "locale=en_US ", "kbd-chooser/method=fr ", "netcfg/get_hostname=${var.hostname} ", "netcfg/get_domain=localdomain ", "fb=false ", "debconf/frontend=noninteractive ", "console-setup/ask_detect=false ", "console-keymaps-at/keymap=fr ", "keyboard-configuration/xkb-keymap=fr ", "net.ifnames=0 ", "<enter><wait>"]
  boot_wait        = "2s"
  disk_interface   = "virtio"
  disk_size        = "24576M"
  headless         = true
  http_directory   = "http"
  iso_checksum     = var.debian_iso_checksum
  iso_url          = var.debian_iso_url
  output_directory = var.output_dir
  qemuargs         = [["-m", "2048M"], ["-smp", "2"]]
  shutdown_command = "echo 'packer' | sudo -S /sbin/shutdown -P now"
  ssh_password     = "packer"
  ssh_port         = 22
  ssh_timeout      = "1200s"
  ssh_username     = "packer"
  vm_name          = "${var.image_name}-${local.timestamp}.qcow2"
}

source "scaleway" "debian" {
  image                 = var.scaleway_id
  commercial_type       = var.scaleway_commercial_type
  ssh_username          = "root"
  ssh_private_key_file  = var.ssh_private_key_file
  zone                  = var.scaleway_default_zone
  image_name            = "${var.image_name}-${local.timestamp}"
}

build {
  sources = ["qemu.debian", "scaleway.debian"]

  provisioner "shell" {
    only    = ["scaleway.debian"]
    inline  = [
      "apt-get update && apt-get -y upgrade"
    ]
  }
}
