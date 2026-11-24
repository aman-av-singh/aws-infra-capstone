\# Project 8 - Docker container on EC2



\- Dockerfile uses nginx:alpine and copies my index.html in.

\- EC2 boot script installs docker, clones this repo, builds image aman-web:v1

&#x20; and runs it with -p 80:80 and --restart always.

\- Proof: docker images / docker ps / curl output from the console log,

&#x20; and the page in a browser on port 80.

\- Issue found: Notepad saved the file as Dockerfile.txt, so the build failed

&#x20; ("open Dockerfile: no such file"). Renamed it and rebuilt only the

&#x20; instance with terraform apply -replace.

\- No SSH used. Destroyed after testing.

