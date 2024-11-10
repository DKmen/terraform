terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "random" {}