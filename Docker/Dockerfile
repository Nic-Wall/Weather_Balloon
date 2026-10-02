# Pulling from https://hub.docker.com/_/debian?tag=stable-20260918-slim
FROM debian:bookworm-20260918-slim
COPY Docker/packages.txt /tmp/packages.txt
RUN apt-get update && apt-get install -y $(grep -vE "^\s*#" /tmp/packages.txt | tr "\n" " ") 
WORKDIR /WB
