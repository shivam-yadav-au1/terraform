
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["172.27.112.0/21", "172.27.120.0/22", "172.27.124.0/22"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["172.27.64.0/20", "172.27.80.0/20", "172.27.96.0/20"]
}

variable "vpc-cidr-range" {
  type        = string
  description = "vpc-cidr"
  default     = "172.27.64.0/18"
}

variable "availability-zones" {
  type        = list(string)
  description = "Availablity zones"
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}


variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}


variable "ami_id_launch_template" {
  type = string
}

variable "availability_zone" {
  type = string
}


variable "cluster_name" {
  type = string
  default = "eks-cluster"
}

variable "redis_cluster_name" {
  type = string
}

variable "environment" {
  type = string

}

variable "redis_auth_token" {
  type    = string
  default = ""
}

variable "vpc_name" {
  type    = string
  default = "smoke-uat"
}

variable "ecs_ec2_server" {
  type    = string
  default = "ECS-ec2-server"
}

variable "ecs_cluster_name" {
  type = string
  default = "ecs_cluster"
}

variable "enable_ecs_cluster" {
  type = bool
  default = false
}

variable "oidc_thumbprint_list" {
  type = string
  default = ""
}

output "openid_connect_provider_arn" {
  value = var.enable_eks_cluster ? aws_iam_openid_connect_provider.cluster[0].arn : null
}

variable "enable_redis_cluster" {
  type = bool
  default = false
}

variable "enable_eks_cluster"{
  type = bool
  default = false
}

# output "aws_ekd_cluster_endpoint" {
#   value =aws_eks_cluster.eks-cluster.endpoint
# }
