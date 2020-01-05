variable "aws_access_key" {
  type        = string
  description = "Access key used to authenticate with AWS"
}

variable "aws_secret_key" {
  type        = string
  description = "Secret key used to authenticate with AWS"
}

variable "aws_region" {
  type        = string
  description = "AWS region you wish to place the infrastructure"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version you would like to run"
}

variable "helm_version" {
  type        = string
  description = "Helm client version you would like to have access to on the node"
}

variable "admin_token" {
  type        = string
  description = "Unique admin token to use within cluster (format: [a-z0-9]{6}\\.[a-z0-9]{16})"
}

variable "host_zone" {
  type        = string
  description = "Route53 host zone used for the cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name given to cluster, accessible via DNS '{cluster_name}.{host_zone}'"
  default     = "Kubernetes"
}

variable "node_type" {
  type        = string
  description = "EC2 instance type used for node"
  default     = "t3.small"
}

variable "node_key" {
  type        = string
  description = "Path to the SSH public key used to access the node"
}
