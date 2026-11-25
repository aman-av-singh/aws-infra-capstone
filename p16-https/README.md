\# Project 16 - HTTPS on the ALB with ACM



\- Same ALB + 2 EC2 setup as P20.

\- Terraform tls provider makes an RSA 2048 private key and a self-signed

&#x20; certificate for the ALB DNS name, then imports it into ACM.

\- HTTPS listener on 443 uses the ACM certificate (TLS 1.3/1.2 security policy).

\- HTTP listener on 80 only redirects to HTTPS (301), so plain HTTP never

&#x20; reaches the servers.

\- Browser shows "not trusted" because the cert is self-signed; a real setup

&#x20; would use an ACM public certificate validated with a domain I own.

\- The private key is only in local Terraform state, which is never committed.

\- Destroyed after testing.

