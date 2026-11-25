provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aman-p10-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "aman-p10-subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "my_rta" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_security_group" "my_sg" {
  name   = "aman-p10-sg"
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0847418ce766a1986"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  user_data              = file("dns-test.sh")

  tags = {
    Name = "aman-p10-web"
  }
}

# Private hosted zone - only works inside this VPC
resource "aws_route53_zone" "internal" {
  name = "aman.internal"

  vpc {
    vpc_id = aws_vpc.my_vpc.id
  }
}

# A record: name -> private IP
resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "web.aman.internal"
  type    = "A"
  ttl     = 60
  records = [aws_instance.web.private_ip]
}

# CNAME record: alias name -> another name
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "www.aman.internal"
  type    = "CNAME"
  ttl     = 60
  records = ["web.aman.internal"]
}

output "instance_id" {
  value = aws_instance.web.id
}

output "private_ip" {
  value = aws_instance.web.private_ip
}