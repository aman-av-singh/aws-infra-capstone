#!/bin/bash
dnf install -y amazon-cloudwatch-agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'CONFIG'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/myapp.log",
            "log_group_name": "aman-p17-logs",
            "log_stream_name": "{instance_id}-myapp"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "aman-p17-logs",
            "log_stream_name": "{instance_id}-cloud-init"
          }
        ]
      }
    }
  }
}
CONFIG
touch /var/log/myapp.log
setsid nohup bash -c 'while true; do echo "$(date) INFO myapp heartbeat - all good" >> /var/log/myapp.log; sleep 10; done' > /dev/null 2>&1 &
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
