# Pulling from https://hub.docker.com/_/debian?tag=stable-20260918-slim
FROM debian:bookworm-20260918-slim
COPY packages.txt /tmp/packages.txt
RUN apt-get update && apt-get install -y $(grep -vE "^\s*#" /tmp/packages.txt | tr "\n" " ") 
RUN useradd -m -u 1000 dev
# User dev is created so all builds are bound to 1000:1000, they're added to sys so they can use mknod in the creation of the rootfs skeleton file system
USER dev
WORKDIR /WB
