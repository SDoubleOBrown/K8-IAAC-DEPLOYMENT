#data "aws_eks_cluster" "cluster" {
#  name = var.cluster_name
#}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = var.cluster_name
}

# Configure the AWS provider
provider "aws" {
  profile = var.AWS_PROFILE
  region  = var.region
}

# Configure the Kubernetes provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}
