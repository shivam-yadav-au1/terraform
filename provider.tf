provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}


provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}