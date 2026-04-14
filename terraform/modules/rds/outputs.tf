output "address" {
  value       = aws_db_instance.mysql.address
  description = "RDS hostname without port"
}

output "rds_address" {
  value       = aws_db_instance.mysql.address
  description = "RDS hostname (alias for address)"
}

output "endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "RDS hostname with port (for reference only)"
}

output "port" {
  value       = aws_db_instance.mysql.port
  description = "RDS port"
}