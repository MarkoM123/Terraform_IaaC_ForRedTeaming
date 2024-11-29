resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "c2_server" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "c2-server"
  }
}

resource "aws_instance" "redirector" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "redirector"
  }
}

resource "aws_instance" "main_server" {
  ami           = "ami-0084a47cc718c111a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.my_key.key_name
  tags = {
    Name = "main-server"
  }
}
