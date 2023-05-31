provider "aws" {
  region = var.net_aws_region
  default_tags {
    tags = {
      environment = var.env
      created_by  = var.created_by
      ManagedBy   = "Env-Build-Terraform"
    }
  }
}

terraform {
  required_providers {
    local = {
      version = "~> 2.1"
    }
  }
}
