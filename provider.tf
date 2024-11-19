provider "aws" {
  region = "us-east-1"
}

terraform {
  cloud {
    organization = "DSB"

    workspaces {
      name = "dsb-aws-devsecops-pipelines"
    }
  }
}