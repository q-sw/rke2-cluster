# Cloud environnement variables
variable "cloud_region" {
  description = "Nom de la region aws"
  default = "eu-west-3"
  type = string
}

variable "aws_ami_id" {
  description = "ID de l'ami à utiliser"
  type = string
}

variable "ssh_key_name" {
  description = "Nom de la clé SSH à utiliser"
  type = string
}

variable "security_group_id" {
  description = "ID du security group à utiliser"
  type = string
}

variable "subnet_id" {
  description = "ID du subnet à utiliser"
  type = string
}

variable "subnet_cidr" {
  description = "CIDR du subnet sous forme de liste"
  type = list
}
# Load balancer variables
variable "lb_instance_flavor" {
  description = "Flavor à utiliser pour le load-balancer"
  default = "t2.small"
  type = string
}

variable "lb_nb" {
  description = "Nombre de load-balancer à déployer"
  default = 1
  type = number
}

variable "lb_net_part" {
  description = "Partie réseau pour les load-balancer"
  type = number
}
# Master variables
variable "master_instance_flavor" {
  description = "Flavor à utiliser pour les master nodes"
  default = "t2.medium"
  type = string
}

variable "master_nb" {
  description = "Nombre de master à déployer"
  default = 1
  type = number
}

variable "master_net_part" {
  description = "Partie réseau pour les masters"
  type = number
}
# Worker variables
variable "worker_instance_flavor" {
  description = "Flavor à utiliser pour les worker nodes"
  default = "t2.medium"
  type = string
}

variable "worker_nb" {
  description = "Nombre de worker à déployer"
  default = 1
  type = number
}

variable "worker_net_part" {
  description = "Partie réseau pour les worker"
  type = number
}
# Project variable
variable "project_tags" {
  description = "Tags par défaut du projet"
  type = map
}