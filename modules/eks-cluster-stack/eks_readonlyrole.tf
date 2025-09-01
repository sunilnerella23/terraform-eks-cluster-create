resource "kubernetes_manifest" "clusterrole_eks_readonly_clusterrole" {
  count = var.enable_readonly_role ? 1 : 0
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "eks-readonly-clusterrole"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "autoscaling",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "rbac.authorization.k8s.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
       {
        "apiGroups" = [
          "external.metrics.k8s.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
{
        "apiGroups" = [
          "apiextensions.k8s.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },   
      {
        "apiGroups" = [
          "monitoring.coreos.com",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },  
      {
        "apiGroups" = [
          "apiregistration.k8s.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
  depends_on = [module.eks]
}

resource "kubernetes_manifest" "clusterrolebinding_readonly_clusterrole_binding" {
  count = var.enable_readonly_role ? 1 : 0
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "readonly-clusterrole-binding"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "eks-readonly-clusterrole"
    }
    "subjects" = [
      {
        "apiGroup" = "rbac.authorization.k8s.io"
        "kind" = "User"
        "name" = "eks-readonly"
      },
    ]
  }
  depends_on = [module.eks]
} 
