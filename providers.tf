#####################################################
# AWS Providers
#####################################################
# Here are the provider declaration
provider "aws" {
  region = var.region_backend
  default_tags {
    tags = {
      "Implementedby" = "Workmates",
      "Managedby"     = "RevUp AI",
      "Environment"   = "POC",
      "Project"       = "RevUp AI"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
#####################################################
