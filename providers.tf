#####################################################
# AWS Providers
#####################################################
# Here are the provider declaration
provider "aws" {
  region = var.region_backend
  default_tags {
    tags = {
      "Implementedby" = "Workmates",
      "Managedby"     = "Csoft",
      "Environment"   = "Prod",
      "Project"       = "Csoft"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
#####################################################
