provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "kubernetes" {
  host                   = var.enable_eks_cluster ? aws_eks_cluster.eks-cluster[0].endpoint : null
  cluster_ca_certificate = base64decode(var.enable_eks_cluster ? aws_eks_cluster.eks-cluster[0].certificate_authority.0.data : "")
  token                  = var.enable_eks_cluster ? data.aws_eks_cluster_auth.eks[0].token : null
}


provider "helm" {
  kubernetes {
    host                   = var.enable_eks_cluster ? aws_eks_cluster.eks-cluster[0].endpoint : null
    cluster_ca_certificate = base64decode(var.enable_eks_cluster ? aws_eks_cluster.eks-cluster[0].certificate_authority.0.data : "")
    token                  = var.enable_eks_cluster ? data.aws_eks_cluster_auth.eks[0].token : null
  }
}