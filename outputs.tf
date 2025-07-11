
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "db_address" {
  description = "RDS endpoint"
  value       = aws_db_instance.devops-test-db.address
}
