resource "kubernetes_config_map_v1_data" "aws_auth_mod" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      concat(
        yamldecode(data.kubernetes_config_map.aws_auth.data["mapRoles"]),
        [
          {
            rolearn  = aws_iam_role.codebuild_role.arn
            username = "${aws_iam_role.codebuild_role.name}-build-user"
            groups   = ["system:masters"]
          },
        ]
      )
    )
    mapUsers = yamlencode(
      concat(
        yamldecode(try(data.kubernetes_config_map.aws_auth.data["mapUsers"], "[]")),
        [
          {
            userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/damien"
            username = "damien"
            groups   = ["system:masters"]
          }
        ]
      )
    )
  }

  force = true
}

