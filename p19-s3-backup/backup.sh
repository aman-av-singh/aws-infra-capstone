#!/bin/bash
dnf install -y cronie
systemctl enable --now crond
cat > /usr/local/bin/backup-logs.sh <<'SCRIPT'
#!/bin/bash
TIME=$(date +%Y-%m-%d_%H-%M)
tar -czf /tmp/logs-$TIME.tar.gz /var/log/cloud-init.log /var/log/dnf.log
aws s3 cp /tmp/logs-$TIME.tar.gz s3://aman-p19-log-backups-2026/backups/ --region eu-west-1
rm -f /tmp/logs-$TIME.tar.gz
SCRIPT
chmod +x /usr/local/bin/backup-logs.sh
echo "* * * * * root /usr/local/bin/backup-logs.sh" > /etc/cron.d/log-backup
