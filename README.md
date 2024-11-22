# AWS DevSecOps Pipeline - Terraform

![License](https://img.shields.io/github/license/The-DevSec-Blueprint/aws-devsecops-pipeline?logo=license)
![Terraform Cloud](https://img.shields.io/badge/Terraform-Registry-purple?logo=terraform)
![GitHub Issues](https://img.shields.io/github/issues/The-DevSec-Blueprint/aws-devsecops-pipeline?logo=github)
![GitHub Forks](https://img.shields.io/github/forks/The-DevSec-Blueprint/aws-devsecops-pipeline?logo=github)
![GitHub Stars](https://img.shields.io/github/stars/The-DevSec-Blueprint/aws-devsecops-pipeline?logo=github)
![GitHub Last Commit](https://img.shields.io/github/last-commit/The-DevSec-Blueprint/aws-devsecops-pipeline?logo=github)
![CI Status](https://github.com/The-DevSec-Blueprint/aws-devsecops-pipeline/actions/workflows/main.yml/badge.svg)

## Overview

This project provides an automated DevSecOps pipeline for deploying infrastructure using Terraform, AWS, and Snyk for vulnerability scanning. The pipeline is designed to streamline infrastructure management while ensuring security through continuous integration and deployment practices.

## Requirements

- **Terraform** (latest stable version)
- **Terraform Cloud** account
- **Snyk** account for vulnerability scanning
- **AWS** account with appropriate permissions

## Setup Instructions

### 1. **Terraform Cloud Setup**

- Create an account on Terraform Cloud and generate an API key.
- Store the API key as a token on your local machine.
- In your GitHub repository settings, add the API token for Terraform Cloud.

### 2. **Configure Terraform**

- Clone or download this repository.
- Update the `terraform-apply.yml` file with your organization name.
- Modify the `provider.tf` file to include your correct Terraform Cloud workspace name (do not use "DSB").
- Move into the `terraform` directory, and enter in the following commands:

```bash
terraform init
terraform plan
```

### 3. **Configure Snyk**

- Create an account on [Snyk](https://www.snyk.io/) and generate an API Token.
- Follow the Snyk CLI [documentation](https://docs.snyk.io/snyk-cli/configure-the-snyk-cli) to configure your CLI.
- Save your Snyk organization ID as an environment variable in Terraform Cloud as a protected `Workspace Variable`:

### 4. **Environment Variables**

Set up the following environment variables within your Terraform Cloud workspace or locally:

- `SNYK_TOKEN`: Your Snyk API token.
- `SNYK_ORG_ID`: Your Snyk organization ID.

### 5. **Terraform Initialization and Apply**

Run the following commands to initialize Terraform, plan the deployment, and apply the changes:

```bash
terraform apply
```

### 6. **Verify AWS Changes**

Log in to the AWS Console and verify the changes made by Terraform:

- Navigate to the AWS [Codesuite Settings](https://us-east-1.console.aws.amazon.com/codesuite/settings/connections?region=us-east-1&connections-meta=eyJmIjp7InRleHQiOiIifSwicyI6e30sIm4iOjIwLCJpIjowfQ#).
- Update the pending connection to make it active.

### 7. **Next Steps**

Once the pipeline is set up and verified, you can move to the next codebase for further configurations or deployments.

## Modules

The `modules` directory contains reusable Terraform modules designed for different parts of the infrastructure. Below is a brief overview of each module:

### 1. **S3 Module**

This module is responsible for provisioning and managing AWS S3 buckets. It defines the main configurations for creating S3 buckets, specifying variables such as bucket name and region.

- **Files**:
  - `main.tf`: S3 bucket creation and configuration.
  - `variables.tf`: Variables such as bucket name, region, etc.
  - `outputs.tf`: Outputs for the S3 bucket, such as the bucket name or ARN.

### 2. **CodePipeline Module**

The CodePipeline module automates the setup of an AWS CodePipeline for continuous integration and deployment. It includes configuration for stages, actions, and integration with other AWS services like ECR and Secrets Manager.

- **Files**:
  - `main.tf`: Defines the pipeline, stages, and actions.
  - `ecr.tf`: Configures ECR (Elastic Container Registry) to store Docker images.
  - `buildspecs`: Contains build instructions for CodeBuild.
  - `secrets.tf`: Configures secrets management for the pipeline.
  - `configmap.tf`: Configures Kubernetes ConfigMaps for integration with EKS (if applicable).
  - `variables.tf`: Defines variables specific to the pipeline.
  - `provider.tf`: Specifies AWS provider details.

### 3. **EKS Module**

This module provisions an EKS (Elastic Kubernetes Service) cluster, including the configuration for node groups and cluster resources.

- **Files**:
  - `main.tf`: Defines the EKS cluster, node groups, and related resources.
  - `variables.tf`: Variables such as cluster name, region, and node configurations.
  - `outputs.tf`: Outputs like the EKS cluster name or endpoint.
