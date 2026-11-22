#!/bin/bash
dnf install -y nginx
echo "<h1>Project 24 - chaos test server</h1>" > /usr/share/nginx/html/index.html
systemctl enable --now nginx
