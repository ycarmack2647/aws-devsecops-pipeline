# Default Networking Configuration
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "${var.region}a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "${var.region}b"
}

# Default Connnection to GitHub
resource "aws_codestarconnections_connection" "default" {
  name          = "dsb-github-connection"
  provider_type = "GitHub"
}

# Default Configurations
module "default_bucket" {
  source        = "./modules/s3"
  bucket_prefix = "${var.resource_prefix}-codepipeline-artifacts"
  bucket_name   = "CodePipelineArtifactsBucket"
}

# EKS Cluster
module "default_cluster" {
  source       = "./modules/eks"
  cluster_name = "${var.resource_prefix}-devsecops-cluster"
  subnet_ids = [
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id
  ]
  node_group_min_size         = 1
  node_group_max_size         = 3
  node_group_desired_capacity = 2
  instance_types              = ["t3.medium"]
  node_group_disk_size        = 20
}

# Pipelines
module "awsome_fastapi_pipeline" {
  source = "./modules/codepipeline"

  github_connection_arn = aws_codestarconnections_connection.default.arn

  s3_bucket_name = module.default_bucket.bucket_name
  s3_bucket_arn  = module.default_bucket.bucket_arn

  repo_name     = "awsome-fastapi"
  repository_id = "The-DevSec-Blueprint/awsome-fastapi"
  branch_name   = "main"

  eks_cluster_name = module.default_cluster.cluster_name
  eks_cluster_arn  = module.default_cluster.cluster_arn
  compute_type     = "BUILD_GENERAL1_SMALL"
  build_image      = "aws/codebuild/standard:5.0"
  environment_type = "LINUX_CONTAINER"
  privileged_mode  = true

  buildspec_path  = file("./buildspecs/awsome-fastapi/build.yml")
  deployspec_path = file("./buildspecs/awsome-fastapi/deploy.yml")

  snyk_org_id = var.SNYK_ORG_ID
  snyk_token  = var.SNYK_TOKEN
}
