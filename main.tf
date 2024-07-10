provider "aws" {
  region = "us-east-1" # Specify your preferred AWS region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyIGW"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Choose your preferred availability zone
  tags = {
    Name = "MySubnet"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (you can change this)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.my_sg.name]
  key_name      = aws_key_pair.my_key.key_name

  tags = {
    Name = "MyInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd git
              systemctl start httpd
              systemctl enable httpd
              cd /var/www/html
              git clone https://github.com/Vimal007Vimal/AWS-1-tier-application.git
              mv AWS-1-tier-application/* /var/www/html/
              EOF
}

output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}

output "instance_dns" {
  value = aws_instance.my_instance.public_dns
}
