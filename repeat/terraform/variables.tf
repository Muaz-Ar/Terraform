variable "aws_region" {
  description = "the value of the region"
  type        = string
  default     = "eu-central-1"
}

variable "machineName" {
  description = "The name of my ec2"
  type        = string
  default     = "server"
}

variable "linux_ami" {
  description = "the value of the ami"
  type        = string
  default     = "ami-025a6a5beb74db87b"
}