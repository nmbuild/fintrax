aws_region = "us-east-1"
db_name = "fintrax_dev"
db_user = "fintraxuser_dev"
db_password = "devpassword"
s3_bucket_name = "fintrax-static-site-dev"
ami_id = "ami-0c02fb55956c7d316"

# EKS configuration - Single cluster for all environments
cluster_name = "fintrax-eks-shared"
kubernetes_version = "1.28"
instance_type = "t3.medium"
desired_capacity = 3  # Increased for multiple environments
max_capacity = 6      # Higher limit for scaling
min_capacity = 2      # Minimum for availability
