provider "aws" {
  region = "eu-west-1"
}

resource "aws_ecr_repository" "web" {
  name         = "aman-p13-web"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "aman-p13-ecr"
  }
}

output "repository_url" {
  value = aws_ecr_repository.web.repository_url
}