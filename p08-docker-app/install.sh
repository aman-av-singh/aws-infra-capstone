#!/bin/bash
dnf install -y docker git
systemctl start docker
systemctl enable docker

cd /root
git clone -b feature/p08-docker https://github.com/aman-av-singh/aws-infra-capstone.git
cd aws-infra-capstone/p08-docker-app

docker build -t aman-web:v1 .
docker run -d --name aman-web -p 80:80 --restart always aman-web:v1
sleep 5

echo "===== DOCKER IMAGES ====="
docker images
echo "===== DOCKER PS ====="
docker ps
echo "===== CURL TEST ====="
curl -s localhost
echo "===== P8 DONE ====="