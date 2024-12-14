resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"
}


resource "helm_release" "alb-controller" {
 name       = "aws-load-balancer-controller"
 repository = "https://aws.github.io/eks-charts"
 chart      = "aws-load-balancer-controller"
 namespace  = "kube-system"
 depends_on = [
     kubernetes_service_account.service-account
 ]

 set {
     name  = "region"
     value = var.availability_zone
 }

 set {
     name  = "vpcId"
     value = aws_vpc.vpc-tf.id
 }

 set {
     name  = "image.repository"
     value = "602401143452.dkr.ecr.${var.availability_zone}.amazonaws.com/amazon/aws-load-balancer-controller"
 }

 set {
     name  = "serviceAccount.create"
     value = "false"
 }

 set {
     name  = "serviceAccount.name"
     value = "aws-load-balancer-controller"
 }

 set {
     name  = "clusterName"
     value = var.enable_eks_cluster ? aws_eks_cluster.eks-cluster[0].name : null
 }
 }