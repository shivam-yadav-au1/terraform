data "tls_certificate" "cluster" {
  count = var.enable_eks_cluster ? 1 : 0
  url = aws_eks_cluster.eks-cluster[count.index].identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  count = var.enable_eks_cluster ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = concat([data.tls_certificate.cluster[count.index].certificates.0.sha1_fingerprint])
  url             = aws_eks_cluster.eks-cluster[count.index].identity.0.oidc.0.issuer
}


module "lb_role" {
  count = var.enable_eks_cluster ? 1 : 0
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "AmazonEKSLoadBalancerControllerRole"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.cluster[count.index].arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}



resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = length(module.lb_role) > 0 ? module.lb_role[0].iam_role_arn : null
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}
