#!/bin/bash
dnf install -y bind-utils

# wait until Route 53 has the record (it is created after the instance)
for i in $(seq 1 30); do
  nslookup web.aman.internal && break
  sleep 10
done

echo "===== NSLOOKUP A RECORD ====="
nslookup web.aman.internal
echo "===== NSLOOKUP CNAME ====="
nslookup www.aman.internal
echo "===== MY PRIVATE IP ====="
hostname -I
echo "===== P10 DONE ====="