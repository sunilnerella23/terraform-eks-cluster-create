variable "role_name" {
  type        = string
  description = "IRSA roles name"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN of EKS cluster"
}
variable "environment" {
  type        = string
  description = "Environment"
}

variable "policy" {
  type = any
  default = {}
}

variable "role_policy_path" {
  type = string
  default = "/eks/"
}