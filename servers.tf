resource "aws_instance" "c2_server" {
  ami           = "ami-12345678" # Zameni stvarnim AMI ID
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name
  tags = {
    Name = "c2-server"
  }
}

resource "aws_instance" "redirector" {
  ami           = "ami-12345678" # Zameni stvarnim AMI ID
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name
  tags = {
    Name = "redirector"
  }
}

resource "aws_instance" "main_server" {
  ami           = "ami-12345678" # Zameni stvarnim AMI ID
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_id
  key_name      = var.key_name
  tags = {
    Name = "main-server"
  }
}
