provider "aws" {
  region = "eu-west-1"
}

# Password for AD recovery mode - typed at apply time, never saved in code
variable "dsrm_password" {
  type      = string
  sensitive = true
}

# Latest Windows Server 2022 image from Amazon
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aman-p09-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "aman-p09-subnet"
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

# No inbound rules at all - no RDP (3389) port opened
resource "aws_security_group" "dc_sg" {
  name   = "aman-p09-dc-sg"
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Role so SSM (Run Command and Fleet Manager) can manage the server
resource "aws_iam_role" "ssm_role" {
  name = "aman-p09-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "aman-p09-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "dc" {
  ami                    = data.aws_ami.windows.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.dc_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
    <powershell>
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Install-ADDSForest -DomainName "aman.local" -DomainNetbiosName "AMAN" -InstallDns -SafeModeAdministratorPassword (ConvertTo-SecureString "${var.dsrm_password}" -AsPlainText -Force) -Force
    </powershell>
  EOF

  tags = {
    Name = "aman-p09-dc"
  }
}

output "instance_id" {
  value = aws_instance.dc.id
}