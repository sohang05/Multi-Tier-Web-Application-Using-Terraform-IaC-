resource "aws_db_subnet_group" "main" {
  name = "rds-subnet-group"

  subnet_ids = [
    var.private_subnet_1,
    var.private_subnet_2
  ]
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password  
  skip_final_snapshot  = true

  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  publicly_accessible = false
}