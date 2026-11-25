\# Project 14 - App on EKS



\- Terraform builds a VPC with 2 public subnets (2 AZs), an EKS cluster and

&#x20; a managed node group (1 x t3.small).

\- Two IAM roles: cluster role (AmazonEKSClusterPolicy) and node role

&#x20; (worker node, CNI and ECR read-only policies).

\- Terraform kubernetes provider connects with the EKS auth token and creates:

&#x20; a Deployment (2 nginx pods) and a Service of type LoadBalancer.

\- AWS created a public load balancer for the Service; the app opened at its

&#x20; DNS name (Welcome to nginx).

\- Destroyed after testing (EKS is billed per hour).

