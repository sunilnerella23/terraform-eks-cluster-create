resource "kubernetes_namespace_v1" "istio_system" {
  count = var.enable_istio ? 1 : 0
  metadata {
    name = "istio-system"
  }
}

module "eks_blueprints_addons_istio" {
  count   = var.enable_istio ? 1 : 0
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # This is required to expose Istio Ingress Gateway

  helm_releases = {
    istio-base = {
      chart      = "base"
      version    = local.istio_chart_version
      repository = local.istio_chart_url
      name       = "istio-base"
      namespace  = kubernetes_namespace_v1.istio_system[0].metadata[0].name
    }

    istiod = {
      chart      = "istiod"
      version    = local.istio_chart_version
      repository = local.istio_chart_url
      name       = "istiod"
      namespace  = kubernetes_namespace_v1.istio_system[0].metadata[0].name

      set = [
        {
          name  = "meshConfig.accessLogFile"
          value = "/dev/stdout"
        }
      ]
    }

    istio-ingress = {
      chart            = "gateway"
      version          = local.istio_chart_version
      repository       = local.istio_chart_url
      name             = "istio-ingress"
      namespace        = "istio-ingress" # per https://github.com/istio/istio/blob/master/manifests/charts/gateways/istio-ingress/values.yaml#L2
      create_namespace = true

      values = [
        yamlencode(
          {
            labels = {
              istio = "ingressgateway"
            }
            service = {
              annotations = {
                "service.beta.kubernetes.io/aws-load-balancer-type"       = "nlb"
                "service.beta.kubernetes.io/aws-load-balancer-scheme"     = "internet-facing"
                "service.beta.kubernetes.io/aws-load-balancer-attributes" = "load_balancing.cross_zone.enabled=true"
              }
            }
          }
        )
      ]
    }
  }

  depends_on = [ module.eks, module.eks_blueprints_addons ]
}

resource "kubectl_manifest" "istio_peer_authentication" {
  count = var.enable_istio && var.enable_istio_peerauth ? 1 : 0
  yaml_body = templatefile("${path.module}/configs/istio_peer_authentication.yaml", {})
  depends_on = [
    module.eks_blueprints_addons_istio
  ]
}
