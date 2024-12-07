resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
# C2 Server Configuration
resource "aws_instance" "c2_server" {
  ami             = "ami-0084a47cc718c111a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.c2_http.id]
  tags = {
    Name = "c2-server"
  }
  provisioner "remote-exec" {
    inline = [
    "apt update",
    "apt-get -y install zip default-jre",
    "cd /opt; wget https://github.com/rapid7/metasploit-framework/archive/refs/heads/master.zip -O metasploit.zip",
    "unzip metasploit.zip",
    "cd metasploit-framework-master",
    "gem install bundler && bundle install",
    "echo \"@reboot root cd /opt/metasploit-framework-master; msfconsole -r /opt/metasploit-framework-master/msfvenom.rc\" >> /etc/cron.d/metasploit",
    "shutdown -r"
  ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.ssh_private_key_path}")
      host        = aws_instance.c2_server.public_ip
    }
  }
}

# C2 Redirector Configuration
resource "aws_instance" "c2_server_redirector" {
  ami             = "ami-0084a47cc718c111a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.operator.id]
  user_data = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "server { listen 80; location / { proxy_pass http://10.0.2.1; } }" > /etc/nginx/sites-enabled/default
    service nginx restart
  EOT
  tags = {
    Name = "c2-server_redirector"
  }
}

# Payload Redirector Configuration
resource "aws_instance" "payload_redirector" {
  ami             = "ami-0084a47cc718c111a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.operator.id]
  user_data = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "server { listen 80; location / { proxy_pass http://10.0.2.1; } }" > /etc/nginx/sites-enabled/default
    service nginx restart
  EOT
  tags = {
    Name = "payload_redirector"
  }
}

# Payload Server Configuration
resource "aws_instance" "payload" {
  ami             = "ami-0084a47cc718c111a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.c2_http.id]
  tags = {
    Name = "payload"
  }
}

# Phishing Server Configuration
resource "aws_instance" "phishing" {
  ami             = "ami-0084a47cc718c111a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.operator.id]
  tags = {
    Name = "Phishing Server"
  }
}

# Phishing Server Redirector Configuration
resource "aws_instance" "phishing_server_redirector" {
  ami             = "ami-0084a47cc718c111a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.operator.id]
  user_data = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "server { listen 80; location / { proxy_pass http://10.0.2.1; } }" > /etc/nginx/sites-enabled/default
    service nginx restart
  EOT
  tags = {
    Name = "SMTP"
  }
}

