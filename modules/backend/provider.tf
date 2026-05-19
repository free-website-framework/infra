terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.32.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Project = var.project
      Env     = var.env
      Managed = "terraform"
    }
  }
}
