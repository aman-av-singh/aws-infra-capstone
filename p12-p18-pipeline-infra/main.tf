terraform {
  backend "s3" {
    bucket       = "aman-tf-state-2026"
    key          = "pipeline-infra/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "demo" {
  bucket = "aman-p12-pipeline-demo-2026"
  tags = {
    Name      = "aman-pipeline-demo"
    ManagedBy = "github-actions"
  }
}