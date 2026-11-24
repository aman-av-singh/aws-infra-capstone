\# Project 13 - Push Docker image to ECR with GitHub Actions



\- Terraform creates ECR repo aman-p13-web (scan on push turned on).

\- Workflow .github/workflows/docker-ecr.yml runs on changes to p08-docker-app.

\- It logs in to ECR, builds the P8 Dockerfile and pushes two tags:

&#x20; the commit SHA and latest.

\- AWS keys come from GitHub Secrets, never from the code.

\- Repo destroyed after testing (force\_delete = true).

