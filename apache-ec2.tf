provider "aws" {
  region = "ap-south-1"
  }

data "aws_ami" "rhel" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = [" "]    //to update
}

resource "aws_security_group" "httpd" {
  name        = "allow_connection"
  description = "Allow Connection for SSH and HTTP"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "aws_security_group"
  }
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.rhel.id
  instance_type = "t2.micro"
  user_data     = <<-EOF
                   #!/bin/bash
                   yum update -y
                   yum install httpd -y
                   service httpd start
                   PUB_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
                   echo "Hello from $${PUB_IP}" > /var/www/html/index.html
                   EOF
  
  key_name = ""   //to update
  tags = {
    Name = "Apache-static-server"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.httpd.id
  network_interface_id = aws_instance.web.primary_network_interface_id
}