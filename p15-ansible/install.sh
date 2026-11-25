#!/bin/bash
export HOME=/root
dnf install -y python3-pip git
pip3 install ansible-core

cd /root
git clone -b feature/p15-ansible https://github.com/aman-av-singh/aws-infra-capstone.git
cd aws-infra-capstone/p15-ansible

echo "===== ANSIBLE RUN ====="
/usr/local/bin/ansible-playbook -i localhost, site.yml
echo "===== CURL TEST ====="
curl -s localhost
echo "===== P15 DONE ====="