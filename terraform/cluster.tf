data "aws_eks_cluster" "k8s-acc" {
  name = aws_eks_cluster.k8s-acc.name
}

resource "aws_eks_cluster" "k8s-acc" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.k8s-acc-cluster.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = concat(aws_subnet.public.*.id, aws_subnet.private.*.id)
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.k8s-acc-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.k8s-acc-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "k8s-acc" {
  cluster_name    = aws_eks_cluster.k8s-acc.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.k8s-acc-node.arn
  subnet_ids      = aws_subnet.private.*.id

  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_desired_size
    min_size     = var.min_desired_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  labels = {
    role = "general"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.k8s-acc-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.k8s-acc-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.k8s-acc-AmazonEC2ContainerRegistryReadOnly,
  ]
}