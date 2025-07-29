output "vpc_id" { 
  value = aws_vpc.main.id 
}

output "k8s_node_ip" { 
  value = aws_instance.k8s_node.public_ip 
}

output "db_endpoint" { 
  value = aws_db_instance.postgres.endpoint 
}

output "s3_bucket" { 
  value = aws_s3_bucket.static.bucket 
}
