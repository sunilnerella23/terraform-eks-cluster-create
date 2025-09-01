module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.2" #ensure to update this to the latest/desired version"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  #eks_addons = var.eks_addons

  enable_aws_efs_csi_driver                    = try(var.enable_aws_efs_csi_driver, false)
  enable_aws_fsx_csi_driver                    = try(var.enable_aws_fsx_csi_driver, false)
  enable_argocd                                = try(var.enable_argocd, false)
  enable_argo_rollouts                         = try(var.enable_argo_rollouts, false)
  enable_argo_workflows                        = try(var.enable_argo_workflows, false)
  enable_aws_cloudwatch_metrics                = try(var.enable_aws_cloudwatch_metrics, false)
  enable_aws_privateca_issuer                  = try(var.enable_aws_privateca_issuer, false)
  enable_cert_manager                          = try(var.enable_cert_manager, false)
  enable_cluster_autoscaler                    = try(var.enable_cluster_autoscaler, false)
  enable_secrets_store_csi_driver              = try(var.enable_secrets_store_csi_driver, false)
  enable_secrets_store_csi_driver_provider_aws = try(var.enable_secrets_store_csi_driver_provider_aws, false)
  enable_kube_prometheus_stack                 = try(var.enable_kube_prometheus_stack, false)
  enable_external_dns                          = try(var.enable_external_dns, false)
  enable_external_secrets                      = try(var.enable_external_secrets, false)
  enable_gatekeeper                            = try(var.enable_gatekeeper, false)
  enable_aws_load_balancer_controller          = try(var.enable_aws_load_balancer_controller, false)
  enable_karpenter                             = try(var.enable_karpenter, false)
  enable_metrics_server                        = try(var.enable_metrics_server, false)

  kube_prometheus_stack = try(var.kube_prometheus_stack, null)

  karpenter_node = var.enable_karpenter ? {
    create_iam_role       = false
    iam_role_arn          = aws_iam_role.karpenter_node_role[0].arn
    iam_role_name         = aws_iam_role.karpenter_node_role[0].name
    instance_profile_name = aws_iam_instance_profile.karpenter_instance_profile[0].name
  } : {}

  #karpenter = var.enable_karpenter ? var.karpenter : null
  karpenter = var.karpenter
  
  enable_aws_for_fluentbit                     = try(var.enable_aws_for_fluentbit, false)
  aws_for_fluentbit = try(var.aws_for_fluentbit, {})

  aws_load_balancer_controller = try(var.aws_load_balancer_controller, {})

  secrets_store_csi_driver =  try(var.secrets_store_csi_driver, {})

  helm_releases = var.eks_addons_helm_releases

  tags = var.tags

}



module "eks_data_addons" {
  source = "aws-ia/eks-data-addons/aws"
  # version = "~> 1.0" # ensure to update this to the latest/desired version

  oidc_provider_arn = module.eks.oidc_provider_arn
  enable_kubecost   = try(var.enable_kubecost, false)

  kubecost_helm_config = try(var.kubecost_helm_config, null)

  # kubecost_helm_config = var.enable_kubecost ? {
  #       values = [
  #       <<-EOT
  #         global:
  #           prometheus:
  #             enabled: false
  #             fqdn: http://kube-prometheus-stack-prometheus.kube-prometheus-stack.svc.cluster.local:9090
  #           grafana:
  #             enabled: true
  #         service:
  #           type: LoadBalancer
  #           annotations: 
  #             service.beta.kubernetes.io/aws-load-balancer-type: external
  #             service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
  #             service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  #         prometheus:
  #           server:
  #             global:
  #               external_labels:
  #                 cluster_id: ${module.eks.cluster_name}
  #       EOT
  #     ] 

  # } : null

}

resource "kubectl_manifest" "local_volume_node_cleanup_controller" {
  count     = try(var.enable_volume_cleanup, false) ? 1 : 0
  yaml_body = file("${path.module}/configs/local_volume_node_cleanup_controller.yaml")
}

data "kubectl_path_documents" "local_volume_node_cleanup_controller_rbac" {
  pattern = "${path.module}/configs/local_volume_node_cleanup_controller_rbac.yaml"
}

resource "kubectl_manifest" "local_volume_node_cleanup_controller_rbac" {
  for_each  = try(var.enable_volume_cleanup, false) ? toset(data.kubectl_path_documents.local_volume_node_cleanup_controller_rbac.documents) : toset([])
  yaml_body = each.value
}

data "aws_secretsmanager_secret_version" "argocd_secret" {
  count     = var.enable_argocd ? 1 : 0
  secret_id = var.argocd_configs.github_token_secret_arn
}

resource "kubernetes_secret" "argocd_secret" {
  count = var.enable_argocd ? 1 : 0
  metadata {
    name = "github-token"
  }

  data = {
    token = data.aws_secretsmanager_secret_version.argocd_secret[0].secret_string
  }
}

# gp3 storage class resource
resource "kubectl_manifest" "gp3_retain_storage_class" {
  yaml_body = file("${path.module}/configs/gp3_storage_class.yaml")
}

# Karpenter Node Pool
resource "kubectl_manifest" "karpenter_nodepool" {
  for_each = var.enable_karpenter ? var.karpenter_nodepools : {}
  
  yaml_body = templatefile("${path.module}/configs/karpenter/node_template.yaml", {
    name = each.value.name
    node_class_ref = each.value.node_class_ref
    labels = each.value.labels
    instance_types = jsonencode(each.value.instance_types)
    capacity_type = jsonencode(each.value.capacity_type)
    zones = jsonencode(each.value.zones)
    taints = each.value.taints
    cpu_limit = each.value.cpu_limit
    memory_limit = each.value.memory_limit
  })

  depends_on = [
    module.eks_blueprints_addons
  ]
}


# Karpenter Node Class
resource "kubectl_manifest" "karpenter_ec2nodeclasses" {
  for_each = var.enable_karpenter ? var.karpenter_ec2_node_classes : {}
  
  yaml_body = templatefile("${path.module}/configs/karpenter/ec2_node_class.yaml", {
    name = each.value.name
    ami_family = each.value.ami_family
    subnet_selector = local.format_subnet_selector[each.key]
    security_group_selector = local.format_security_group_selector[each.key]
    ami_selector = local.format_ami_selector[each.key]
    #instance_profile = try(each.value.role_name, aws_iam_instance_profile.karpenter_instance_profile[0].name)
    instance_profile = try(each.value.role_name, aws_iam_role.karpenter_node_role[0].name)
    tags = local.format_tags[each.key]
    device_name = each.value.block_device_mappings.deviceName
    volume_size = each.value.block_device_mappings.ebs.volumeSize
    volume_type = each.value.block_device_mappings.ebs.volumeType
    encrypted = each.value.block_device_mappings.ebs.encrypted
    delete_on_termination = each.value.block_device_mappings.ebs.deleteOnTermination
    userdata = indent(4, file("${path.module}/configs/custom_userdata.tmpl"))
  })

  depends_on = [
    module.eks_blueprints_addons
  ]
}


resource "aws_iam_role" "karpenter_node_role" {
  count = var.enable_karpenter ? 1 : 0
  # name  = "eks-${var.environment}-karpenter-node-role"
  name = try("${var.karpenter_configs.role_name_prefix}-${var.environment}-karpenter-node-role",
  "${var.environment}-karpenter-node-role")
  #REPLACE HERE
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_role_attachment" {
  for_each   = var.enable_karpenter ? { for i, val in local.policies : i => val } : {}
  role       = aws_iam_role.karpenter_node_role[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  count = var.enable_karpenter ? 1 : 0
  name  = "${var.environment}-karpenter-node"
  path  = var.role_policy_path
  ##REPLACE HERE
  role = aws_iam_role.karpenter_node_role[0].name
}


module "mimir_irsa" {
  source                = "./modules/irsa"
  role_name             = var.mimir_irsa.app_name
  policy                = var.mimir_irsa.policy
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  environment           = var.environment
  role_policy_path      = var.role_policy_path
}

data "kubectl_path_documents" "kyverno_manifests" {
  pattern = "${path.module}/configs/kyverno/*.yaml"
}


resource "kubectl_manifest" "kyverno_notation_namespace" {
  yaml_body = templatefile("${path.module}/configs/kyverno/kyverno-notation-ns.yaml",{})
}

resource "kubectl_manifest" "kyverno_manifests" {
  depends_on = [ kubectl_manifest.serviceaccount_kyverno_notation_aws ]
  for_each  = try(var.enable_kyverno_notation_aws, false) ? toset(data.kubectl_path_documents.kyverno_manifests.documents) : toset([])
  yaml_body = each.value
}

resource "kubectl_manifest" "serviceaccount_kyverno_notation_aws" {
  count = var.enable_kyverno_notation_aws ? 1 : 0
  depends_on = [ kubectl_manifest.kyverno_notation_namespace ]
  yaml_body = templatefile("${path.module}/configs/kyverno-serviceaccount.yaml", {
    iam_role_arn = module.iam_eks_role.iam_role_arn
  })
}


data "aws_region" "current" {}
locals {
  regions = {
    "us-east-1"      = "us1",
    "eu-west-2"      = "eu2",
    "eu-west-1"      = "eu1",
    "ap-southeast-1" = "ap1"
  }

}
module "iam_eks_role" {
  version = "5.60.0"
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.environment}-${lookup(local.regions, data.aws_region.current.name)}-kyverno-IRSA"

  role_policy_arns = {
    policy = module.iam_policy.arn
  }
  role_path = var.role_policy_path

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*:kyverno-notation-aws"]
    }
  }
  assume_role_condition_test = "StringLike"
}

module "iam_policy" {
  version = "5.60.0"
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name   = "${var.environment}-${lookup(local.regions, data.aws_region.current.name)}-kyverno-policy"
  path   = var.role_policy_path

  policy = jsonencode(
    {
      Version : "2012-10-17"
      Statement : [
        {
          Sid : ""
          Action : [
            "ecr:*",
            "signer:*"
          ]
          Effect : "Allow"
          Resource : [
            "*"
          ]
        }
      ]
    }
  )
}
