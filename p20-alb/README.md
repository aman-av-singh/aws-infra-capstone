\# Project 20 - ALB with 2 EC2 instances



\- VPC with 2 public subnets in eu-west-1a and eu-west-1b (an ALB needs 2 AZs).

\- web1 and web2 run nginx, each with its own page so you can see which one answered.

\- ALB listener on port 80 forwards to a target group with both instances.

\- Health check on "/" every 10 s; 2 fails = unhealthy, 2 passes = healthy.

\- Web servers only accept port 80 from the ALB security group, not from the internet.

\- Proof: target health, curl loop alternating, failover when web1 stopped.

\- Destroyed after testing.

