terraform {
  backend "s3" {
    bucket = "techstarter-mo-terraform-state"
    key = "state/terraform.tfstate"
    region = "eu-central-1"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}

