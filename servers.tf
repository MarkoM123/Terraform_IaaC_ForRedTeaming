resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "c2_server" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "c2-server"
  }
}
resource "aws_instance" "c2_server_redirector" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "c2-server"
  }
}


resource "aws_instance" "payload_redirector" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "payload_redirector"
  }
}
resource "aws_instance" "payload" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "payload"
  }
}


resource "aws_instance" "phishing_server" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "Phishing"
  }
}

resource "aws_instance" "phishing_server_redirector" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "SMTP"
  }
}
