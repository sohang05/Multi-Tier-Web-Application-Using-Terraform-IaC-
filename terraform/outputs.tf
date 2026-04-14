output "app_url" {
  value = module.alb.alb_dns
}

output "backend_private_ip" {
  value = module.backend.private_ip
}

output "debug_backend_sg" {
  value = module.sg.backend_sg_id
}

output "rds_address" {
  value = module.rds.rds_address
}

