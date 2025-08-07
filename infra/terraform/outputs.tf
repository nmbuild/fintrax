output "vpc_id" { 
  value = aws_vpc.main.id 
}

output "eks_cluster_name" { 
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" { 
  value = module.eks.cluster_endpoint
}

output "eks_cluster_region" { 
  value = var.aws_region
}

output "eks_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "db_endpoint" { 
  value = aws_db_instance.postgres.endpoint 
}

output "s3_bucket" { 
  value = aws_s3_bucket.static.bucket 
}
