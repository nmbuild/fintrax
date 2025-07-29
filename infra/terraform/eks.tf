# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "fintrax-eks"
  cluster_version = "1.28"
  subnets         = [aws_subnet.main.id]
  vpc_id          = aws_vpc.main.id
  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}

output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "eks_kubeconfig" { value = module.eks.kubeconfig }
