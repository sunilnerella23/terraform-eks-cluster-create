data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "mgmt" {
  provider = aws.mgmt
  name = local.mgmt_cluster.cluster_name
}

provider "aws" {
  alias = "mgmt"
  assume_role {
    role_arn = local.mgmt_cluster.role_arn
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file        = false
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubernetes" {
  alias = "mgmt"
  host = local.mgmt_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(local.mgmt_cluster.cluster_ca_certificate)
  token = data.aws_eks_cluster_auth.mgmt.token
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command = "aws"
  #   args = ["eks","get-token","--cluster-name",local.mgmt_cluster.cluster_name,"--role-arn",local.mgmt_cluster.role_arn]
  # }
}
