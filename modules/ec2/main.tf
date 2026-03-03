# AMI
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]  # official debian ami
  
  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# key pair
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-ssh-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
  
  tags = {
    Name = "bastion-ssh-key"
  }
}

# Security Groups
resource "aws_security_group" "task1_sg_allow_ssh" {
  
  name        = "allow-ssh-${var.name_suffix}"
  description = "Security Group allowing ssh access to ${var.environment} environment"
  
  tags = {
    Name      = "allow-ssh-${var.name_suffix}"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = var.whitelisted_ips
    description     = "Allow SSH access."
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group" "task1_sg_allow_http_https" {
  
  name        = "allow-http-https-${var.name_suffix}"
  description = "Security Group allowing http and https traffic to bastion"
  
  tags = {
    Name      = "allow-http-https-${var.name_suffix}"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow HTTP traffic."
  }
  
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow HTTPS traffic."
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}


resource "aws_eip" "task1_eip" {
  instance = aws_instance.task1_bastion.id
  domain   = "vpc"
  
  depends_on  = [aws_instance.task1_bastion]

  tags = {
    Name      = "bastion-${var.name_suffix}"
  }  
}

# EC2 instance - bastion
resource "aws_instance" "task1_bastion" {
  ami = data.aws_ami.debian.id

  instance_type = "m7i-flex.large"
  key_name      = aws_key_pair.bastion_key.key_name

  source_dest_check           = false
  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true   

  root_block_device {
    volume_type = "gp2"
    volume_size = 30
    encrypted = true
    delete_on_termination = false
  }

  tags = {
    Name        = "bastion-${var.name_suffix}"
  }

  # attaching security group
  vpc_security_group_ids = [
    aws_security_group.task1_sg_allow_ssh.id,
    aws_security_group.task1_sg_allow_http_https.id,
    var.cloudhsm_security_group_id
  ] 

  lifecycle {
    ignore_changes  = [
      ami,
      user_data,
      root_block_device[0].volume_size
    ]
  }
}