# Project 4 - IAM user with S3 read policy

- Terraform creates IAM user aman-p04-s3-reader
- Policy JSON is stored in a variable (variables.tf) and attached to the user
- Access key creation is blocked by the organization SCP, so testing was done with the IAM policy simulator
- Policy test: S3 list/get allowed, put/delete and EC2 implicitly denied (least privilege)
- Real user test: explicitly denied by the organization SCP, which overrides all account policies
