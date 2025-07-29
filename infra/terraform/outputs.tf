output "vpc_id" { value = aws_vpc.main.id }
output "instance_id" { value = aws_instance.app.id }
output "db_endpoint" { value = aws_db_instance.postgres.endpoint }
output "s3_bucket" { value = aws_s3_bucket.static.bucket }
