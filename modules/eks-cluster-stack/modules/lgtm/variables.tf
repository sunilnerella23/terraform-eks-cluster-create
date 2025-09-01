variable "loki_bucket_name" {
  type        = string
  description = "Bucket name for Loki S3 bucket"
  default     = "sandbox-eks-loki"
}

variable "mimir_bucket_name" {
  type        = string
  description = "Bucket name for Mimir S3 bucket"
  default     = "eks-mimir"
}

variable "ruler_bucket_name" {
  type        = string
  description = "Bucket name for Ruler S3 bucket"
  default     = "eks-ruler"
}

variable "alertmgr_bucket_name" {
  type        = string
  description = "Bucket name for AlertMgr S3 bucket"
  default     = "eks-alertmgr"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "sandbox"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN of EKS cluster"
}

variable "acm_certificate_arn" {
  type = string
}

variable "role_policy_path" {
  type = string
  default = "/eks/"
}

variable "enable_mimir" {
  type = bool
  default = false
}

variable "enable_memcache_chunk" {
  type = bool
  default = false
}

variable "enable_memcache_result" {
  type = bool
  default = false
}