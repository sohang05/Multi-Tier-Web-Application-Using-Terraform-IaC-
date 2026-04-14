resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.name}-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  
  associate_public_ip_address = true

  key_name = var.key_name

  user_data = var.user_data

  tags = {
    Name = var.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional" 
  }
  
}
