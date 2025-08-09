aws_region = "us-east-1"
db_name = "fintrax_staging"
db_user = "fintraxuser_staging"
db_password = "stagingpassword"
s3_bucket_name = "fintrax-static-site-staging"
ami_id = "ami-0c02fb55956c7d316"

# EKS configuration - Uses same shared cluster
cluster_name = "fintrax-eks-dev"
kubernetes_version = "1.32"
instance_type = "t3.medium"
desired_capacity = 3
max_capacity = 6
min_capacity = 2
