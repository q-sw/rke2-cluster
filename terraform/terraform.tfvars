# Cloud environnement variables
cloud_region           = "eu-west-3"
aws_ami_id             = "ami-06d79c60d7454e2af"
ssh_key_name           = "aws_perso"
security_group_id      = "sg-0d7e46957e04dc12a"
subnet_id              = "subnet-fb0da0b6"
subnet_cidr			   = ["172","31","32","0","/20"]
# Load balancer variables
lb_instance_flavor     = "t2.small"
lb_nb				   = 1
lb_net_part			   = 10
# Master variables
master_instance_flavor = "t2.medium"
master_nb              = 1
master_net_part		   = 20
# Worker variables
worker_instance_flavor = "t2.medium"
worker_nb              = 1
worker_net_part		   = 30
# Project variable
project_tags		   = {
	project_name = "RKE2_CLUSTER",
	auto_shutdown = "true"
}