terraform {
  backend "s3" {
    bucket         	   = "node-app-tfstate"
    key              	 = "state/terraform.tfstate"
    region         	   = "us-east-1"
    encrypt        	   = true
    dynamodb_table     = "node_app_lockid"
  }
}

provider "aws" {
  region = var.region
}
