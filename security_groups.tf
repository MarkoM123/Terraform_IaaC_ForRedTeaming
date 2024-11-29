# C2 Server Security Group
resource "aws_security_group" "c2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTP/HTTPS"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["212.200.247.75/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Redirector Security Group
resource "aws_security_group" "redirector_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTP/HTTPS"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Main Server Security Group
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow SSH from Redirectors"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.redirector_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
