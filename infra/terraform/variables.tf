variable "aws_region" { default = "us-east-1" }
variable "ami_id" {}
variable "db_name" { default = "fintrax" }
variable "db_user" { default = "fintraxuser" }
variable "db_password" {}
variable "s3_bucket_name" { default = "fintrax-static-site" }
