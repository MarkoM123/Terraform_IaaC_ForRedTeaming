resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags       = { Name = "Private Subnet" }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  tags       = { Name = "Public Subnet" }
  map_public_ip_on_launch = true  # Ova opcija automatski dodeljuje javnu IP adresu

}
resource "aws_security_group" "c2_http" {
  name        = "c2-http"
  description = "Security group za c2-http - HTTP i HTTPS pristup"
  vpc_id      = aws_vpc.main.id  # Povezivanje sa VPC-om definisanim kao "main"

  ingress {
    description = "SSH pristup samo sa operator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip]  # IP adresa operatora koja mora biti definisana u varijablama
  }

  ingress {
    description = "HTTP pristup sa svih IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Pristup sa svih IP
  }

  ingress {
    description = "HTTPS pristup sa svih IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Pristup sa svih IP
  }

  egress {
    description = "Pristup za DNS preko UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP i HTTPS ka svim IP"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "operator" {
  name        = "operator"
  description = "Security group za operator pristup"
  vpc_id      = aws_vpc.main.id  # Isto povezivanje sa VPC-om definisanim kao "main"

  ingress {
    description = "Operator port 50050"
    from_port   = 50050
    to_port     = 50050
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip]  # IP adresa operatora
  }
}

resource "aws_security_group" "phishing" {
  name        = "phishing"
  description = "Security group za phishing droplet"
  vpc_id      = aws_vpc.main.id  # Isto povezivanje sa VPC-om definisanim kao "main"

  ingress {
    description = "Phishing port 3333"
    from_port   = 3333
    to_port     = 3333
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip]  # IP adresa operatora
  }

  egress {
    description = "Pristup SMTP relay-u na portu 25"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Otvoreno ka svim IP adresama
  }
}

resource "aws_security_group" "smtp_relay" {
  name        = "smtp-relay"
  description = "Security group za SMTP relay"
  vpc_id      = aws_vpc.main.id  # Isto povezivanje sa VPC-om definisanim kao "main"

  ingress {
    description = "SMTP relay port 25"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = [aws_instance.phishing.public_ip]  # Phishing instanca
  }

  egress {
    description = "SMTP port 25 - outgoing"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Otvoreno ka svim IP
  }
}
