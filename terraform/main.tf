# Data sources to fetch existing resources

data "aws_eks_cluster" "demo" {
  name = var.cluster_name
}

# Import existing demo-cluster from workshop infrastructure
import {
  to = aws_eks_cluster.demo
  id = data.aws_eks_cluster.demo.id
}


resource "aws_iam_role" "cluster_role" {
  name = var.cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

# Attach required policies to cluster role
locals {
  eks_policies = [
    "AmazonEKSComputePolicy",
    "AmazonEKSBlockStoragePolicy",
    "AmazonEKSLoadBalancingPolicy",
    "AmazonEKSNetworkingPolicy"
  ]
}

# Attach all policies using for_each with toset
resource "aws_iam_role_policy_attachment" "eks_policies" {
  for_each = toset(local.eks_policies)

  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Modify imported EKS cluster

resource "aws_eks_cluster" "demo" {
  name     = data.aws_eks_cluster.demo.id
  role_arn = var.cluster_role_arn

  # Preserve existing configuration
  enabled_cluster_log_types = data.aws_eks_cluster.demo.enabled_cluster_log_types

  vpc_config {
    subnet_ids         = data.aws_eks_cluster.demo.vpc_config[0].subnet_ids
    security_group_ids = data.aws_eks_cluster.demo.vpc_config[0].security_group_ids
  }

  # EKS Auto Mode requirements
  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["system", "general-purpose"]
    node_role_arn = var.node_role_arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  # Preserve existing tags
  tags = data.aws_eks_cluster.demo.tags

  # Dependency to attach cluster role policies needed for EKS Auto Mode
  depends_on = [
    aws_iam_role_policy_attachment.eks_policies
  ]
}
