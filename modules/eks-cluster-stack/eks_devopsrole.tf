resource "kubernetes_manifest" "clusterrole_eks_devops_clusterrole" {
  count = var.enable_devops_role ? 1 : 0
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "eks-devops-clusterrole"
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
          "watch",
          "create",
          "update",
          "patch",
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
          "watch",
          "create",
          "update",
          "patch",
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
          "watch",
          "create",
          "update",
          "patch",
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
          "watch",
          "create",
          "update",
          "patch",
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
          "watch",
          "create",
          "update",
          "patch",
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
          "watch",
          "create",
          "update",
          "patch",
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
          "create",
          "update",
          "patch",
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
          "create",
          "update",
          "patch",
        ]
      }, 
    ]
   
  }
  depends_on = [module.eks]
}

resource "kubernetes_manifest" "clusterrolebinding_devops_clusterrole_binding" {
  count = var.enable_devops_role ? 1 : 0
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "devops-clusterrole-binding"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "eks-devops-clusterrole"
    }
    "subjects" = [
      {
        "apiGroup" = "rbac.authorization.k8s.io"
        "kind" = "User"
        "name" = "eks-devops"
      },
    ]
  }
  depends_on = [module.eks]
} 

