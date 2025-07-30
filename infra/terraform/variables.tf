variable "aws_region" { default = "us-east-1" }
variable "ami_id" {}
variable "db_name" { default = "fintrax" }
variable "db_user" { default = "fintraxuser" }
variable "db_password" {}
variable "s3_bucket_name" { default = "fintrax-static-site" }

# EKS Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "fintrax-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of nodes in the EKS cluster"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of nodes in the EKS cluster"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "Minimum number of nodes in the EKS cluster"
  type        = number
  default     = 1
}
