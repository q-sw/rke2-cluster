terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.68.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.1.0"
    }
  }
}

provider "aws" {
  region = var.cloud_region
}

resource "aws_network_interface" "lb_int" {
  count = var.lb_nb
  subnet_id   = var.subnet_id
  private_ips = ["${join(".", slice(var.subnet_cidr, 0, 3))}.${var.lb_net_part+count.index}"]
  security_groups = [var.security_group_id]

  tags = {
    Name = format("lb_interface_%s", count.index)
  }
}

resource "aws_instance" "lb" {
  count                  = var.lb_nb
  ami                    = var.aws_ami_id
  instance_type          = var.lb_instance_flavor
  key_name               = var.ssh_key_name
  network_interface {
    network_interface_id = element(aws_network_interface.lb_int.*.id, count.index)
    device_index         = 0
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }
  tags = merge({Name=format("lb%s", count.index)}, var.project_tags)
}

resource "aws_network_interface" "master_int" {
  count       = var.master_nb
  subnet_id   = var.subnet_id
  private_ips = ["${join(".", slice(var.subnet_cidr, 0, 3))}.${var.master_net_part+count.index}"]
  security_groups = [var.security_group_id]

  tags = {
    Name = format("master_interface_%s", count.index)
  }
}

resource "aws_instance" "master" {
  count                  = var.master_nb
  ami                    = var.aws_ami_id
  instance_type          = var.master_instance_flavor
  key_name               = var.ssh_key_name
  network_interface {
    network_interface_id = element(aws_network_interface.master_int.*.id, count.index)
    device_index         = 0
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }
  tags = merge({Name=format("master%s", count.index)}, var.project_tags)

}

resource "aws_network_interface" "worker_int" {
  count       = var.master_nb
  subnet_id   = var.subnet_id
  private_ips = ["${join(".", slice(var.subnet_cidr, 0, 3))}.${var.worker_net_part+count.index}"]
  security_groups = [var.security_group_id]

  tags = {
    Name = format("worker_interface_%s", count.index)
  }
}

resource "aws_instance" "worker" {
  count                  = var.worker_nb
  ami                    = var.aws_ami_id
  instance_type          = var.worker_instance_flavor
  key_name               = var.ssh_key_name
  network_interface {
    network_interface_id = element(aws_network_interface.worker_int.*.id, count.index)
    device_index         = 0
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }
  tags = merge({Name=format("worker%s", count.index)}, var.project_tags)
}

resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tpl",
    {
      loadbalancer = aws_instance.lb
      master = aws_instance.master
      additionnal_master = length(aws_instance.master)== 1 ? aws_instance.master : slice(aws_instance.master, 1, length(aws_instance.master))
      worker = aws_instance.worker
    }
  )
  filename = "../ansible/inventory.yaml"
}

resource "local_file" "ansible_infrastructure_vars" {
  content = templatefile("templates/infrastructure.tpl",
    {
      loadbalancer = aws_instance.lb
      master = aws_instance.master
      additionnal_master = length(aws_instance.master)== 1 ? aws_instance.master : slice(aws_instance.master, 1, length(aws_instance.master))
      worker = aws_instance.worker
    }
  )
  filename = "../ansible/group_vars/all/infrastructure.yaml"
}