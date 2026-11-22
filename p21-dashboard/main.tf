provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "aman-p21-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
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
  name   = "aman-p21-sg"
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
  user_data              = file("wave.sh")
  tags = {
    Name = "aman-p21-server"
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "aman-p21-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          title   = "EC2 CPU Utilization (%)"
          region  = "eu-west-1"
          stat    = "Average"
          period  = 60
          metrics = [["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.server.id]]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Network In (bytes)"
          region  = "eu-west-1"
          stat    = "Sum"
          period  = 60
          metrics = [["AWS/EC2", "NetworkIn", "InstanceId", aws_instance.server.id]]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Network Out (bytes)"
          region  = "eu-west-1"
          stat    = "Sum"
          period  = 60
          metrics = [["AWS/EC2", "NetworkOut", "InstanceId", aws_instance.server.id]]
        }
      }
    ]
  })
}

output "dashboard_url" {
  value = "https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#dashboards/dashboard/aman-p21-dashboard"
}