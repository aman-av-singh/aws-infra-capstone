#!/bin/bash
sleep 30
echo "===== P23 TEST START ====="
aws sts get-caller-identity
echo "--- s3 ls (should work) ---"
aws s3 ls | head -5
echo "--- ec2 describe (should be denied) ---"
aws ec2 describe-instances --region eu-west-1
echo "===== P23 TEST END ====="
