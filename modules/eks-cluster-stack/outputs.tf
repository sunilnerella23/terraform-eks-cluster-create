################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = try(module.eks.cluster_arn, null)
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(module.eks.cluster_certificate_authority_data, null)
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(module.eks.cluster_endpoint, null)
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = try(module.eks.cluster_id, "")
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(module.eks.cluster_name, "")
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = try(module.eks.cluster_oidc_issuer_url, null)
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = try(module.eks.cluster_version, null)
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = try(module.eks.cluster_platform_version, null)
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = try(module.eks.cluster_status, null)
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = try(module.eks.cluster_primary_security_group_id, null)
}

# ################################################################################
# # KMS Key
# ################################################################################

# output "kms_key_arn" {
#   description = "The Amazon Resource Name (ARN) of the key"
#   value       = module.kms.key_arn
# }

# output "kms_key_id" {
#   description = "The globally unique identifier for the key"
#   value       = module.kms.key_id
# }

# output "kms_key_policy" {
#   description = "The IAM resource policy set on the key"
#   value       = module.kms.key_policy
# }

# ################################################################################
# # Cluster Security Group
# ################################################################################

# output "cluster_security_group_arn" {
#   description = "Amazon Resource Name (ARN) of the cluster security group"
#   value       = try(aws_security_group.cluster[0].arn, null)
# }

# output "cluster_security_group_id" {
#   description = "ID of the cluster security group"
#   value       = try(aws_security_group.cluster[0].id, null)
# }

# ################################################################################
# # Node Security Group
# ################################################################################

# output "node_security_group_arn" {
#   description = "Amazon Resource Name (ARN) of the node shared security group"
#   value       = try(aws_security_group.node[0].arn, null)
# }

# output "node_security_group_id" {
#   description = "ID of the node shared security group"
#   value       = try(aws_security_group.node[0].id, null)
# }

# ################################################################################
# # IRSA
# ################################################################################

# output "oidc_provider" {
#   description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
#   value       = try(replace(module.eks.identity[0].oidc[0].issuer, "https://", ""), null)
# }

# output "oidc_provider_arn" {
#   description = "The ARN of the OIDC Provider if `enable_irsa = true`"
#   value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, null)
# }

# output "cluster_tls_certificate_sha1_fingerprint" {
#   description = "The SHA1 fingerprint of the public key of the cluster's certificate"
#   value       = try(data.tls_certificate.this[0].certificates[0].sha1_fingerprint, null)
# }

# ################################################################################
# # IAM Role
# ################################################################################

# output "cluster_iam_role_name" {
#   description = "IAM role name of the EKS cluster"
#   value       = try(aws_iam_role.this[0].name, null)
# }

# output "cluster_iam_role_arn" {
#   description = "IAM role ARN of the EKS cluster"
#   value       = try(aws_iam_role.this[0].arn, null)
# }

# output "cluster_iam_role_unique_id" {
#   description = "Stable and unique string identifying the IAM role"
#   value       = try(aws_iam_role.this[0].unique_id, null)
# }

# ################################################################################
# # EKS Addons
# ################################################################################

output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = module.eks.cluster_addons
}

# ################################################################################
# # EKS Identity Provider
# ################################################################################

# output "cluster_identity_providers" {
#   description = "Map of attribute maps for all EKS identity providers enabled"
#   value       = aws_eks_identity_provider_config.this
# }

# ################################################################################
# # CloudWatch Log Group
# ################################################################################

# output "cloudwatch_log_group_name" {
#   description = "Name of cloudwatch log group created"
#   value       = try(aws_cloudwatch_log_group.this[0].name, null)
# }

# output "cloudwatch_log_group_arn" {
#   description = "Arn of cloudwatch log group created"
#   value       = try(aws_cloudwatch_log_group.this[0].arn, null)
# }

# ################################################################################
# # Fargate Profile
# ################################################################################

# output "fargate_profiles" {
#   description = "Map of attribute maps for all EKS Fargate Profiles created"
#   value       = module.fargate_profile
# }

# ################################################################################
# # EKS Managed Node Group
# ################################################################################

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

# ################################################################################
# # Self Managed Node Group
# ################################################################################

# output "self_managed_node_groups" {
#   description = "Map of attribute maps for all self managed node groups created"
#   value       = module.self_managed_node_group
# }

# output "self_managed_node_groups_autoscaling_group_names" {
#   description = "List of the autoscaling group names created by self-managed node groups"
#   value       = compact([for group in module.self_managed_node_group : group.autoscaling_group_name])
# }

# ################################################################################
# # Additional
# ################################################################################

# output "aws_auth_configmap_yaml" {
#   description = "[DEPRECATED - use `var.manage_aws_auth_configmap`] Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
#   value = templatefile("${path.module}/templates/aws_auth_cm.tpl",
#     {
#       eks_managed_role_arns                   = distinct(compact([for group in module.eks._managed_node_group : group.iam_role_arn]))
#       self_managed_role_arns                  = distinct(compact([for group in module.self_managed_node_group : group.iam_role_arn if group.platform != "windows"]))
#       win32_self_managed_role_arns            = distinct(compact([for group in module.self_managed_node_group : group.iam_role_arn if group.platform == "windows"]))
#       fargate_profile_pod_execution_role_arns = distinct(compact([for group in module.fargate_profile : group.fargate_profile_pod_execution_role_arn]))
#     }
#   )
# }

# Addons Outputs
# output "argo_rollouts" {
#   description = "Map of attributes of the Helm release created"
#   value       = module.argo_rollouts
# }

# output "argo_workflows" {
#   description = "Map of attributes of the Helm release created"
#   value       = module.argo_workflows
# }

# output "argocd" {
#   description = "Map of attributes of the Helm release created"
#   value       = module.argocd
# }

# output "argo_events" {
#   description = "Map of attributes of the Helm release created"
#   value       = module.argo_events
# }

# output "aws_cloudwatch_metrics" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.aws_cloudwatch_metrics
# }

# output "aws_efs_csi_driver" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.aws_efs_csi_driver
# }

# output "aws_for_fluentbit" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.aws_for_fluentbit
# }

# output "aws_fsx_csi_driver" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.aws_fsx_csi_driver
# }

# output "aws_load_balancer_controller" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.aws_load_balancer_controller
# }

# output "aws_node_termination_handler" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value = merge(
#     module.aws_node_termination_handler,
#     {
#       sqs = module.aws_node_termination_handler_sqs
#     }
#   )
# }

# output "aws_privateca_issuer" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.aws_privateca_issuer
# }

# output "cert_manager" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.cert_manager
# }

# output "cluster_autoscaler" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.cluster_autoscaler
# }

# output "cluster_proportional_autoscaler" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.cluster_proportional_autoscaler
# }

# output "eks_addons" {
#   description = "Map of attributes for each EKS addons enabled"
#   value       = aws_eks_addon.this
# }

# output "external_dns" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.external_dns
# }

# output "external_secrets" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.external_secrets
# }

# output "fargate_fluentbit" {
#   description = "Map of attributes of the configmap and IAM policy created"
#   value = {
#     configmap  = kubernetes_config_map_v1.aws_logging
#     iam_policy = aws_iam_policy.fargate_fluentbit
#   }
# }

# output "gatekeeper" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.gatekeeper
# }

# output "ingress_nginx" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.ingress_nginx
# }

# output "karpenter" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value = merge(
#     module.karpenter,
#     {
#       node_instance_profile_name = try(aws_iam_instance_profile.karpenter[0].name, "")
#       node_iam_role_arn          = try(aws_iam_role.karpenter[0].arn, "")
#       sqs                        = module.karpenter_sqs
#     }
#   )
# }

# output "kube_prometheus_stack" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.kube_prometheus_stack
# }

# output "metrics_server" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.metrics_server
# }

# output "secrets_store_csi_driver" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.secrets_store_csi_driver
# }

# output "secrets_store_csi_driver_provider_aws" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.secrets_store_csi_driver_provider_aws
# }

# output "velero" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.velero
# }

# output "vpa" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.vpa
# }

# output "aws_gateway_api_controller" {
#   description = "Map of attributes of the Helm release and IRSA created"
#   value       = module.aws_gateway_api_controller
# }

# ################################################################################
# # (Generic) Helm Release
# ################################################################################

# output "helm_releases" {
#   description = "Map of attributes of the Helm release created"
#   value       = helm_release.this
# }

# ################################################################################
# # GitOps Bridge
# ################################################################################
# /*
# This output is intended to be used with GitOps when the addons' Helm charts
# are going to be installed by a GitOps tool such as ArgoCD or FluxCD.
# We guarantee that this output will be maintained any time a new addon is
# added or an addon is updated, and new metadata for the Helm chart is needed.
# */
# output "gitops_metadata" {
#   description = "GitOps Bridge metadata"
#   value = merge(
#     { for k, v in {
#       iam_role_arn    = module.cert_manager.iam_role_arn
#       namespace       = local.cert_manager_namespace
#       service_account = local.cert_manager_service_account
#       } : "cert_manager_${k}" => v if var.enable_cert_manager
#     },
#     { for k, v in {
#       iam_role_arn    = module.cluster_autoscaler.iam_role_arn
#       namespace       = local.cluster_autoscaler_namespace
#       service_account = local.cluster_autoscaler_service_account
#       } : "cluster_autoscaler_${k}" => v if var.enable_cluster_autoscaler
#     },
#     { for k, v in {
#       iam_role_arn    = module.aws_cloudwatch_metrics.iam_role_arn
#       namespace       = local.aws_cloudwatch_metrics_namespace
#       service_account = local.aws_cloudwatch_metrics_service_account
#       } : "aws_cloudwatch_metrics_${k}" => v if var.enable_aws_cloudwatch_metrics
#     },
#     { for k, v in {
#       iam_role_arn               = module.aws_efs_csi_driver.iam_role_arn
#       namespace                  = local.aws_efs_csi_driver_namespace
#       controller_service_account = local.aws_efs_csi_driver_controller_service_account
#       node_service_account       = local.aws_efs_csi_driver_node_service_account
#       } : "aws_efs_csi_driver_${k}" => v if var.enable_aws_efs_csi_driver
#     },
#     { for k, v in {
#       iam_role_arn               = module.aws_fsx_csi_driver.iam_role_arn
#       namespace                  = local.aws_fsx_csi_driver_namespace
#       controller_service_account = local.aws_fsx_csi_driver_controller_service_account
#       node_service_account       = local.aws_fsx_csi_driver_node_service_account
#       } : "aws_fsx_csi_driver_${k}" => v if var.enable_aws_fsx_csi_driver
#     },
#     { for k, v in {
#       iam_role_arn    = module.aws_privateca_issuer.iam_role_arn
#       namespace       = local.aws_privateca_issuer_namespace
#       service_account = local.aws_privateca_issuer_service_account
#       } : "aws_privateca_issuer_${k}" => v if var.enable_aws_privateca_issuer
#     },
#     { for k, v in {
#       iam_role_arn    = module.external_dns.iam_role_arn
#       namespace       = local.external_dns_namespace
#       service_account = local.external_dns_service_account
#       } : "external_dns_${k}" => v if var.enable_external_dns
#     },
#     { for k, v in {
#       iam_role_arn    = module.external_secrets.iam_role_arn
#       namespace       = local.external_secrets_namespace
#       service_account = local.external_secrets_service_account
#       } : "external_secrets_${k}" => v if var.enable_external_secrets
#     },
#     { for k, v in {
#       iam_role_arn    = module.aws_load_balancer_controller.iam_role_arn
#       namespace       = local.aws_load_balancer_controller_namespace
#       service_account = local.aws_load_balancer_controller_service_account
#       } : "aws_load_balancer_controller_${k}" => v if var.enable_aws_load_balancer_controller
#     },
#     { for k, v in {
#       iam_role_arn    = module.aws_for_fluentbit.iam_role_arn
#       namespace       = local.aws_for_fluentbit_namespace
#       service_account = local.aws_for_fluentbit_service_account
#       log_group_name  = try(aws_cloudwatch_log_group.aws_for_fluentbit[0].name, null)
#       } : "aws_for_fluentbit_${k}" => v if var.enable_aws_for_fluentbit && v != null
#     },
#     { for k, v in {
#       iam_role_arn    = module.aws_node_termination_handler.iam_role_arn
#       namespace       = local.aws_node_termination_handler_namespace
#       service_account = local.aws_node_termination_handler_service_account
#       sqs_queue_url   = module.aws_node_termination_handler_sqs.queue_url
#       } : "aws_node_termination_handler_${k}" => v if var.enable_aws_node_termination_handler
#     },
#     { for k, v in {
#       iam_role_arn               = module.karpenter.iam_role_arn
#       namespace                  = local.karpenter_namespace
#       service_account            = local.karpenter_service_account_name
#       sqs_queue_name             = module.karpenter_sqs.queue_name
#       node_instance_profile_name = local.karpenter_node_instance_profile_name
#       } : "karpenter_${k}" => v if var.enable_karpenter
#     },
#     { for k, v in {
#       iam_role_arn    = module.velero.iam_role_arn
#       namespace       = local.velero_namespace
#       service_account = local.velero_service_account
#       } : "velero_${k}" => v if var.enable_velero
#     },
#     { for k, v in {
#       iam_role_arn    = module.aws_gateway_api_controller.iam_role_arn
#       namespace       = local.aws_gateway_api_controller_namespace
#       service_account = local.aws_gateway_api_controller_service_account
#       } : "aws_gateway_api_controller_${k}" => v if var.enable_aws_gateway_api_controller
#     },
#     { for k, v in {
#       group_name    = try(var.fargate_fluentbit.cwlog_group, aws_cloudwatch_log_group.fargate_fluentbit[0].name, null)
#       stream_prefix = local.fargate_fluentbit_cwlog_stream_prefix
#       } : "fargate_fluentbit_log_${k}" => v if var.enable_fargate_fluentbit && v != null
#     }
#   )
# }