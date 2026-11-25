\# Project 10 - Internal DNS



\- Route 53 private hosted zone aman.internal, attached to my VPC only.

\- A record web.aman.internal -> EC2 private IP; CNAME www.aman.internal -> web.

\- VPC has enable\_dns\_support and enable\_dns\_hostnames on (needed for private zones).

\- EC2 boot script runs nslookup on both names; output read from the console log.

\- Names do not resolve from the internet, only inside the VPC.

\- Destroyed after testing.

