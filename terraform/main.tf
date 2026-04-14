resource "aws_key_pair" "my_key" {
  key_name   = "terra-key-ec2"
  public_key = file("terra-key-ec2.pub") 
}

module "vpc" {
  source = "./modules/vpc"
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

# Frontend EC2
module "frontend" {
  source    = "./modules/ec2"
  ami       = "ami-0ec10929233384c7f"
  subnet_id = module.vpc.public_subnets[0]
  sg_id     = module.sg.frontend_sg_id

  key_name = aws_key_pair.my_key.key_name

  name      = "frontend"
  user_data = templatefile("${path.module}/scripts/frontend.sh", {
  backend_ip = module.backend.private_ip
})
  depends_on = [module.backend]
}

# Backend EC2
module "backend" {
  source    = "./modules/ec2"
  ami       = "ami-0ec10929233384c7f"
  
  subnet_id = module.vpc.private_subnets[0]
  sg_id     = module.sg.backend_sg_id

  key_name = aws_key_pair.my_key.key_name

  name      = "backend"
  user_data = templatefile("${path.module}/scripts/backend.sh",{
    db_host = module.rds.address
  })
}

module "alb" {
  source = "./modules/alb"

  vpc_id      = module.vpc.vpc_id
  subnets     = module.vpc.public_subnets  
  sg_id       = module.sg.alb_sg
  instance_id = module.frontend.instance_id
}

module "rds" {
  source = "./modules/rds"
  
  db_name = module.rds.db_name
  db_username = module.rds.db_username
  db_password = module.rds.db_password
  private_subnet_1 = module.vpc.private_subnets[0]
  private_subnet_2 = module.vpc.private_subnets[1]
  rds_sg_id        = module.sg.rds_sg
}