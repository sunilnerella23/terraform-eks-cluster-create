# Istion Addon Locals
locals {
  istio_chart_url     = "https://istio-release.storage.googleapis.com/charts"
  istio_chart_version = "1.18.1"

  policies = [
    aws_iam_policy.secret_access.arn,
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    aws_iam_policy.ec2_volumes_access.arn
  ]

  managed_node_group_configs = {
    for key, config in var.eks_managed_node_groups :
    "${key}" => {
      min_size                   = config.min_size
      max_size                   = config.max_size
      desired_size               = config.desired_size
      instance_types             = config.instance_types
      capacity_type              = config.capacity_type
      labels                     = config.labels
      use_custom_launch_template = true
      create_launch_template     = false
      launch_template_id         = try(config.launch_template_id, aws_launch_template.custom_launch_template.id)
      launch_template_version    = try(config.launch_template_version, 1)
      create_iam_role            = false
      iam_role_arn               = aws_iam_role.eks_node_role.arn
      ami_type                   = try(config.ami_type, null)
      taints                     = try(config.taints, {})
      subnet_ids = try(config.subnet_ids, var.subnet_ids)
      # ami_id                     = try(config.ami_id, "")
      # New changes
      ami_release_version = try(config.ami_release_version, null)
      cluster_version = try(config.cluster_version, null)
      use_latest_ami_release_version = try(config.use_latest_ami_release_version, false)
      force_update_version = try(config.force_update_version, false)      
    }
  }

  mgmt_cluster = {
    cluster_endpoint = var.register_as_spoke ? try(data.terraform_remote_state.mgmt_cluster[0].outputs.cluster_endpoint, module.eks.cluster_endpoint) : module.eks.cluster_endpoint

    cluster_ca_certificate = var.register_as_spoke ? try(data.terraform_remote_state.mgmt_cluster[0].outputs.cluster_certificate_authority_data, module.eks.cluster_certificate_authority_data) : module.eks.cluster_certificate_authority_data

    cluster_name = var.register_as_spoke ? try(data.terraform_remote_state.mgmt_cluster[0].outputs.cluster_name, module.eks.cluster_name) : module.eks.cluster_name

    role_arn = var.register_as_spoke ? var.management_cluster_state.role_arn : var.assume_role
  }

  combined_manifest_content = join("\n---\n", [for file in fileset("${path.module}/configs/kyverno", "*.yaml") : file("${path.module}/configs/kyverno/${file}")])
}


# Karpenter Node Class formatting
locals {
  # Format subnet selector based on provided values
  format_subnet_selector = {
    for k, v in var.karpenter_ec2_node_classes : k => (
      try(v.subnet_selector.tags, null) != null ? "tags:\n      ${join("\n      ", [for key, value in v.subnet_selector.tags : "${key}: ${value}"])}" :
      try(v.subnet_selector.id, null) != null ? "id: ${v.subnet_selector.id}" :
      try(v.subnet_selector.name, null) != null ? "name: ${v.subnet_selector.name}" : 
      "tags:\n      karpenter.sh/discovery: ${var.cluster_name}"
    )
  }

  # Format security group selector based on provided values
  format_security_group_selector = {
    for k, v in var.karpenter_ec2_node_classes : k => (
      try(v.security_group_selector.tags, null) != null ? "tags:\n      ${join("\n      ", [for key, value in v.security_group_selector.tags : "${key}: ${value}"])}" :
      try(v.security_group_selector.id, null) != null ? "id: ${v.security_group_selector.id}" :
      try(v.security_group_selector.name, null) != null ? "name: ${v.security_group_selector.name}" : 
      "tags:\n      aws:eks:cluster-name: ${var.cluster_name}"
    )
  }

  # Format AMI selector based on provided values
  format_ami_selector = {
    for k, v in var.karpenter_ec2_node_classes : k => (
      try(v.ami_selector.alias, null) != null ? "alias: ${v.ami_selector.alias}" :
      try(v.ami_selector.tags, null) != null ? "tags:\n      ${join("\n      ", [for key, value in v.ami_selector.tags : "${key}: ${value}"])}" :
      try(v.ami_selector.id, null) != null ? "id: ${v.ami_selector.id}" :
      "alias: al2023@latest"
    )
  }

  # Format tags
  format_tags = {
    for k, v in var.karpenter_ec2_node_classes : k => join("\n    ", [
      for key, value in v.tags : "${key}: ${value}"
    ])
  }
}