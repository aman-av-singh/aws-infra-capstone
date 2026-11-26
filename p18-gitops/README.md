\# Project 18 - GitOps infra deployment



\- Workflow .github/workflows/terraform-apply.yml runs only on push to main,

&#x20; which happens when a PR is merged.

\- It runs terraform init + apply on p12-p18-pipeline-infra (S3 backend with

&#x20; locking, same state as P12), so Git is the single source of truth:

&#x20; merge = deploy.

\- P12 runs plan on the PR for review; P18 applies after the merge.

\- Destroyed afterwards from my laptop (same remote state).

