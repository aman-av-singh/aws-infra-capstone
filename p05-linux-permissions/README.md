# Project 5 - Secure Linux server permissions

Setup (setup.sh, run at boot on Amazon Linux 2023):
- Created group developers and users alice and bob
- Added alice to developers; bob is not a member
- Created /projects/dev owned by root:developers with chmod 770

Results:
- alice (group member) could write a file: ALLOWED
- bob (not a member) could not write or list the folder: Permission denied

Why: 770 gives full access to the owner and group, and none to others.
Group membership decides access, so users can be granted or removed
by changing groups, without touching file permissions.
