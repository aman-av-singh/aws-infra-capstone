provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "aman-p03-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "aman-p03-subnet"
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
  name   = "aman-p03-sg"
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-0847418ce766a1986"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  monitoring             = true
  user_data              = file("load.sh")
  tags = {
    Name = "aman-p03-server"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "aman-p03-cpu-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "aman.av.singh@accenture.com"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "aman-p03-cpu-high"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "CPU above 70 percent for 2 minutes"
  dimensions = {
    InstanceId = aws_instance.server.id
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

output "instance_id" {
  value = aws_instance.server.id
}