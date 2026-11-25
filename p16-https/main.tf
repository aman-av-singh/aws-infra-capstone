provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "aman-p16-vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "aman-p16-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "aman-p16-subnet-b"
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

resource "aws_route_table_association" "rta_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "rta_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.my_rt.id
}

# ALB security group - port 80 (for redirect) and 443 (HTTPS)
resource "aws_security_group" "alb_sg" {
  name   = "aman-p16-alb-sg"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Web server security group - port 80 only from the ALB
resource "aws_security_group" "web_sg" {
  name   = "aman-p16-web-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web1" {
  ami                    = "ami-0847418ce766a1986"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum install -y nginx
    echo "<h1>Hello over HTTPS - Server 1</h1>" > /usr/share/nginx/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF

  tags = {
    Name = "aman-p16-web1"
  }
}

resource "aws_instance" "web2" {
  ami                    = "ami-0847418ce766a1986"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_b.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum install -y nginx
    echo "<h1>Hello over HTTPS - Server 2</h1>" > /usr/share/nginx/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF

  tags = {
    Name = "aman-p16-web2"
  }
}

resource "aws_lb" "my_alb" {
  name               = "aman-p16-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_lb_target_group" "web_tg" {
  name                 = "aman-p16-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.my_vpc.id
  deregistration_delay = 30

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_target_group_attachment" "web1_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# ---------- Certificate ----------

# 1. Private key
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. Self-signed certificate for the ALB's DNS name
resource "tls_self_signed_cert" "my_cert" {
  private_key_pem = tls_private_key.my_key.private_key_pem

  subject {
    common_name  = "aman-p16.example.com"
    organization = "Aman Capstone"
  }

  dns_names             = [aws_lb.my_alb.dns_name]
  validity_period_hours = 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# 3. Import it into ACM
resource "aws_acm_certificate" "imported" {
  private_key      = tls_private_key.my_key.private_key_pem
  certificate_body = tls_self_signed_cert.my_cert.cert_pem

  tags = {
    Name = "aman-p16-cert"
  }
}

# ---------- Listeners ----------

# HTTPS on 443 - forwards to the servers
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.imported.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# HTTP on 80 - only redirects to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

output "alb_dns" {
  value = aws_lb.my_alb.dns_name
}

output "certificate_arn" {
  value = aws_acm_certificate.imported.arn
}