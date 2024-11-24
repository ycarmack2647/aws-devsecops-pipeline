provider "aws" {
  region = var.region
}

provider "random" {}

terraform {
  cloud {
    organization = "DSB"

    workspaces {
      name = "dsb-aws-devsecops-pipelines"
    }
  }
}