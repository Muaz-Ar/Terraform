terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
variable "zone" {
  type = string
  default = "eu-central-1"
}
provider "aws" {
  region = var.zone

}

resource "aws_instance" "myInstance" {
  ami = "ami-025a6a5beb74db87b"
  instance_type = "t2.micro"
  availability_zone = "${var.zone}a"
  vpc_security_group_ids = ["sg-0b5b0c0c9bbbd7245"]
  subnet_id = "subnet-0a797027072d5dd03"
  
  tags = {
    "Name" = "myInstanceMO"
    
  }
}

resource "aws_ec2_instance_state" "run" {
  instance_id = aws_instance.myInstance.id
  state = "running"
}