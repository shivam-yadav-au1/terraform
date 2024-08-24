# data "http" "lbc_iam_policy" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
#   # Optional request headers
#   request_headers = {
#     Accept = "application/json"
#   }
# }

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks-cluster.name
}
