terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use an appropriate version constraint
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26.0" # Use an appropriate version constraint
    }
  }
}