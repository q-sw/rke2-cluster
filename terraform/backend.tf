terraform {
  backend "s3" {
    bucket = "qsw-terraform-state"
    key    = "eu-west-3/rke2-cluster/terraform.tfstate"
    region = "eu-west-3"
    encrypt = false
  }
}