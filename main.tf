resource "random_id" "id" {
  byte_length = 8
}

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "codepipeline-artifacts-${random_id.id.hex}"

  tags = {
    Name        = "CodePipelineArtifactsBucket"
    Environment = "DevSecOps"
  }
}

resource "aws_secretsmanager_secret" "github_token" {
  name        = "github-oauth-token"
  description = "GitHub OAuth token for CodePipeline access"
}

resource "aws_secretsmanager_secret_version" "github_token" {
  secret_id     = aws_secretsmanager_secret.github_token.id
  secret_string = "your-personal-access-token" # Replace this with the GitHub Personal Access Token
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.resource_prefix}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "CodePipelinePolicy-${random_id.id.hex}"
  description = "Policy for CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "codebuild:*",
          "iam:PassRole",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.resource_prefix}-devsecops-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.id
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = "your-github-username"
        Repo       = "your-repository-name"
        Branch     = "main"
        OAuthToken = aws_secretsmanager_secret_version.github_token.secret_string
      }
    }
  }


  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  stage {
    name = "Scan"

    action {
      name            = "StaticCodeAnalysis"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.static_analysis_project.name
      }
    }
  }
}

resource "aws_codebuild_project" "build_project" {
  name         = "${var.resource_prefix}-build-prj"
  service_role = aws_iam_role.codepipeline_role.arn

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("./buildspecs/buildproject.yml")
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "static_analysis_project" {
  name         = "${var.resource_prefix}-sast-scanning-prj"
  service_role = aws_iam_role.codepipeline_role.arn

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("./buildspecs/sastscanning.yml")
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "oss_scanning_project" {
  name         = "${var.resource_prefix}-oss-scanning-prj"
  service_role = aws_iam_role.codepipeline_role.arn

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("./buildspecs/ossdepscan.yml")
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}
