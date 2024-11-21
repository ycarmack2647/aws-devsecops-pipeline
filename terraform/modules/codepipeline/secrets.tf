# SSM Parameters
resource "aws_ssm_parameter" "snyk_token" {
  name  = "/credentials/snyk/auth_token"
  type  = "SecureString"
  value = var.snyk_token
}

resource "aws_ssm_parameter" "snyk_org_id" {
  name  = "/credentials/snyk/org_id"
  type  = "String"
  value = var.snyk_org_id
}