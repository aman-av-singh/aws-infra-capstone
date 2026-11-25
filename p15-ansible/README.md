\# Project 15 - Ansible configuration management



\- Playbook site.yml: install nginx (dnf), copy index.html (copy), start and

&#x20; enable nginx (service). become: true for root.

\- SSH (port 22) is not allowed on this account, so the EC2 instance runs the

&#x20; playbook against itself with connection: local. Its boot script installs

&#x20; ansible-core, clones this repo and runs ansible-playbook.

\- Proof: PLAY RECAP with failed=0 in the console log, and the page on port 80.

\- Running it again would show changed=0, because Ansible modules are idempotent.

\- Destroyed after testing.

