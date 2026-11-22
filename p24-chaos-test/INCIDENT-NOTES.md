# Incident notes - Project 24 manual chaos test

## Summary
Planned chaos test. The nginx web service on aman-p24-web
(i-0acfad616d177d69d, eu-west-1) was stopped on purpose to test
detection and recovery. Service was restored with no lasting impact.

## Timeline (IST, 22 Nov 2026)
- 19:11:30 - Fault injected: "systemctl stop nginx" sent via SSM Run Command
- 19:12:00 - Detected: health check (curl) returned HTTP 000 (no response)
- 19:12:42 - Recovery started: "systemctl start nginx" sent via SSM
- 19:13:21 - Verified: nginx reported "active", health check returned HTTP 200

## Impact
Website unavailable for about 1 minute 51 seconds.

## Metrics
- Time to detect (MTTD): about 30 seconds
- Time to recover (MTTR): about 1 minute 21 seconds after detection

## How it was fixed
Restarted nginx remotely with SSM Run Command (no SSH, port 22 closed).

## Lessons learned
- Detection was manual (curl). A CloudWatch alarm or ALB health
  check would detect it automatically.
- Recovery was manual. A systemd "Restart=always" setting or an
  Auto Scaling group with health checks could recover it automatically.
- SSM Run Command allowed safe remote fixes without opening SSH.
