#!/bin/bash
yum install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Project 1 - Web server made with Terraform by Aman</h1>" > /usr/share/nginx/html/index.html
