#!/bin/bash
sleep 20
echo "===== P5 TEST START ====="
groupadd developers
useradd -m alice
useradd -m bob
usermod -aG developers alice
mkdir -p /projects/dev
chown root:developers /projects/dev
chmod 770 /projects/dev
echo "--- users and groups ---"
id alice
id bob
echo "--- folder permissions ---"
ls -ld /projects/dev
echo "--- alice (in developers) writes a file ---"
su - alice -c "echo hello > /projects/dev/alice.txt && echo ALLOWED"
echo "--- bob (not in developers) writes a file ---"
su - bob -c "echo hello > /projects/dev/bob.txt && echo ALLOWED"
echo "--- bob lists the folder ---"
su - bob -c "ls /projects/dev"
echo "--- final folder contents ---"
ls -l /projects/dev
echo "===== P5 TEST END ====="
