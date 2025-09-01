# -  AWS EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  cluster_addons = var.cluster_addons

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = var.self_managed_node_group_defaults

  self_managed_node_groups = var.self_managed_node_groups

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults

  eks_managed_node_groups = local.managed_node_group_configs

  # Fargate Profile(s)
  fargate_profile_defaults = var.fargate_profile_defaults
  fargate_profiles         = var.fargate_profiles
 # Cluster access entry
  # # To add the current caller identity as an administrator
  # enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  # authentication_mode                      = var.authentication_mode 
  # access_entries = var.access_entries


  # aws-auth configmap
  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  aws_auth_roles = var.enable_karpenter ? concat(var.aws_auth_roles,
    [
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.karpenter_node_role[0].name}"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
      }
    ]
  ) : var.aws_auth_roles

  aws_auth_users = var.aws_auth_users

  aws_auth_accounts = var.aws_auth_accounts

  #tags = var.tags
  tags = merge(var.tags, {"STO-WizEKSAutoConnect":"True"})

  node_security_group_additional_rules = var.node_security_group_additional_rules

  iam_role_path = var.role_policy_path
  #REPLACE HERE 
  cluster_encryption_policy_path = var.role_policy_path
}

module "irsa" {
  for_each              = { for i, v in var.irsa_configs : i => v }
  source                = "./modules/irsa"
  role_name             = each.value.app_name
  policy                = each.value.policy
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  environment           = var.environment
  role_policy_path = var.role_policy_path
}


resource "kubectl_manifest" "dashboard_frontend_ingress" {
  count = try(var.dashboard_frontend_ingress, false) ? 1 : 0
  yaml_body = templatefile("${path.module}/configs/master_ingress.yaml", {
    environment = var.environment,
    scheme      = "internal",
    app_type    = "dashboard-frontend",
    certificate = var.ingress_cert
  })
}

resource "kubectl_manifest" "dashboard_api_ingress" {
  count = try(var.dashboard_api_ingress, false) ? 1 : 0
  yaml_body = templatefile("${path.module}/configs/master_ingress.yaml", {
    environment = var.environment,
    scheme      = "internal",
    app_type    = "dashboard-api",
    certificate = var.ingress_cert
  })
}

resource "kubectl_manifest" "ingress_groups" {
  for_each = var.ingress_groups
  yaml_body = templatefile("${path.module}/configs/master_ingress.yaml", {
    environment = var.environment,
    scheme      = each.value.scheme
    app_type    = each.value.group_name,
    certificate = each.value.certificate
  })
}

module "observability" {
  source                = "./modules/lgtm"
  loki_bucket_name      = "eks-loki-data"
  environment           = var.environment
  enable_memcache_chunk = var.enable_memcache_chunk
  enable_memcache_result= var.enable_memcache_result
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  acm_certificate_arn = var.grafana_certificate
  depends_on = [ module.eks_blueprints_addons, module.eks ]
  role_policy_path = var.role_policy_path
}

module "security_groups" {
  for_each = var.security_groups
  source = "./modules/sg"
  name = try(each.value.name, null)
  description = try(each.value.description, null)
  vpc_id = each.value.vpc_id
  ingress_rules = try(each.value.ingress_rules, {})
  egress_rules = try(each.value.egress_rules, {})
  tags = try(each.value.tags, {})
}

module "network_load_balancers" {
  for_each = var.network_load_balancers
  source = "./modules/loadbalancer"
  lb_name = each.value.lb_name
  internal = try(each.value.internal, true)
  load_balancer_type = try(each.value.load_balancer_type, "network")
  subnets = each.value.subnets
  delete_protection = try(each.value.delete_protection, false)
  tags = try(each.value.tags, {})
  target_groups = try(each.value.target_groups, {})
  security_groups = try(each.value.security_groups, [])
  listeners = try(each.value.listeners, {})
}

resource "aws_iam_role" "argocd_spoke_role" {
  name = "argocd-spoke-${var.environment}"
  path = var.role_policy_path
  #REPLACE HERE
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = var.argocd_controller_role_arn
        }
      }
    ]
  })
}

resource "kubernetes_secret" "spoke_cluster_secret" {
  count = var.register_as_spoke ? 1 : 0
  provider = kubernetes.mgmt
  metadata {
    name = "argo-spoke-${data.aws_caller_identity.current.account_id}-${module.eks.cluster_name}"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
    namespace = "argocd"
  }

  data = {
    config = jsonencode(
      {
        awsAuthConfig = {
          clusterName = module.eks.cluster_name
          roleARN = aws_iam_role.argocd_spoke_role.arn
        }
        tlsClientConfig = {
          caData = module.eks.cluster_certificate_authority_data
        }
      }
    )
    name = "argo-spoke-${data.aws_caller_identity.current.account_id}-${module.eks.cluster_name}"
    server = module.eks.cluster_endpoint
  }
}
