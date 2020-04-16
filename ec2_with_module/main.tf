provider "aws" {
  region = "us-east-1"
}

variable "subnet_id" {
}

# data "terraform_remote_state" "base-stack" {
#   backend = "s3"
#   config = {
#     bucket = "devopsology-tf-max"
#     key    = "baseSetup/terraform.tfstate"
#     region = "us-east-1"
#   }
# }


module "ec2-instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.13.0"
  ami                         = "ami-00eb20669e0990cb4"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  name                        = "simple_instance"
  subnet_id                   = var.subnet_id
  # subnet_id = element(split(",", lookup(data.terraform_remote_state.base-stack.outputs.SubnetIdsMap, "dev")), 1)

  tags = {
    Name = "First instance"
  }
}

module "ec2-instance-web" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.13.0"
  ami                         = "ami-00eb20669e0990cb4"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  name                        = "web_instance"
  subnet_id                   = var.subnet_id
  # subnet_id = element(split(",", lookup(data.terraform_remote_state.base-stack.outputs.SubnetIdsMap, "stage")), 1)

  tags = {
    Name = "Second instance"
  }
}