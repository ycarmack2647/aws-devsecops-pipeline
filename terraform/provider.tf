provider "aws" {
  region = var.region
}

terraform {
  cloud {
    organization = "DSB"

    workspaces {
      name = "dsb-aws-devsecops-pipelines"
    }
  }
}