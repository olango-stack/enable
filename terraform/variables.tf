variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "your-region"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "your-cluster-name"
}

variable "cluster_role_arn" {
  description = "EKS Cluster role ARN"
  type        = string
  default     = "your-cluster-role-arn"
}

variable "cluster_role_name" {
  description = "EKS Cluster role name"
  type        = string
  default     = "your-cluster-role-name"
}

variable "node_role_arn" {
  description = "EKS Node role ARN"
  type        = string
  default     = "your-node-role-arn"
}

