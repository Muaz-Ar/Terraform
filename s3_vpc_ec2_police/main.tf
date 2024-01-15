terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.region
}

# configurieren der vpc 

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"

}


resource "aws_instance" "my_instance" {
  ami           = "ami-025a6a5beb74db87b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "hausaufgabe12-01-2024"
  }
}



resource "aws_s3_bucket" "my_bucket" {
  bucket = "hallo-test-12121"
 
}


resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:*",
        "Resource" : "arn:aws:s3:::hallo-test-12121/*",
        "Condition" : {
          "StringEquals" : {
            "aws:userid" : "your_ec2_instance_arn"
          }
        }
      }
    ]
  })
}