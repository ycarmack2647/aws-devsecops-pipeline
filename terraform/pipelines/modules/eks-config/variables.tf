variable "roles" {
  description = "List of roles to add to aws-auth"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

variable "users" {
  description = "List of users to add to aws-auth"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}