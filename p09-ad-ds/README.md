\# Project 9 - Windows Server AD DS domain controller



\- Windows Server 2022 on EC2 (t3.medium), managed only through SSM:

&#x20; no RDP port 3389 opened, security group has no inbound rules.

\- Boot script installs AD-Domain-Services and runs Install-ADDSForest to

&#x20; create the domain aman.local (NetBIOS AMAN) with DNS. Server reboots and

&#x20; becomes the domain controller (EC2AMAZ-8JOFHU6.aman.local).

\- DSRM password is a Terraform sensitive variable typed at apply time,

&#x20; never stored in code.

\- AD objects created with SSM Run Command (PowerShell) from the CLI:

&#x20; OU Capstone, group Developers, users alice and aman.admin;

&#x20; alice in Developers, aman.admin in Domain Admins.

\- Domain user login proof: LDAP bind as AMAN\\alice with her password

&#x20; returned "alice domain login OK".

\- Desktop login through Fleet Manager Remote Desktop was not possible:

&#x20; the console role has no SSM permissions ("Can't fetch managed nodes"),

&#x20; and RDP port 3389 is not allowed on this account.

\- The file with user passwords (users.json) is in .gitignore and not committed.

\- Destroyed after testing.

