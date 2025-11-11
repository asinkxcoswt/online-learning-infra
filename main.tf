terraform {
  backend "s3" {
    bucket         = "online-learning-tf-state-bucket"
    key            = "sites/test/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }

  required_version = ">=1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

