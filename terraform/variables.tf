variable "AWS_ACCESS_KEY_ID" {
  description = "AWS access key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS secret access key"
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default     = "MainVPC" # Replace with the actual default value
}

variable "bucket_name" {
  description = "Name of the s3 Bucket"
  default     = "altschool-terraform-state-backend"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "availability_zones" {
  description = "AWS Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_name" {
  description = "Name prefix for public subnets"
  default     = "public-subnet"
}

variable "private_subnet_name" {
  description = "Name prefix for private subnets"
  default     = "private-subnet"
}

variable "public_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "eks_cluster_role" {
  type    = string
  default = "eks-role"
}
variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.25"
}

variable "eks_node_group_iam" {
  type    = string
  default = "eks-node-iam"
}
variable "node_group_name" {
  type    = string
  default = "eks-node-group"
}
variable "desired_size" {
  type    = number
  default = 2
}

variable "max_desired_size" {
  type    = number
  default = 3
}

variable "min_desired_size" {
  type    = number
  default = 1
}

variable "max_unavailable" {
  type    = number
  default = 1
}

variable "instance_types" {
  default = ["t3.medium"]
}
