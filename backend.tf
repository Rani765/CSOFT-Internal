terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    tls = {
      source = "hashicorp/tls"
    }

  }

  backend "s3" {
    region       = "us-east-1"
    encrypt      = true
    bucket       = "csoft-terraform-statefiles-dippanita"
    use_lockfile = true
    key          = "terraform.tfstate"
  }
}