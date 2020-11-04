# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java (glibc support)
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM findepi/graalvm:20.2.0-java11

LABEL maintainer="Juan Cedeno <cto@noobsters.net>"

RUN apt-get update -y && apt upgrade -y && apt autoremove -y \
    && apt-get install -y curl ca-certificates openssl git tar sqlite fontconfig tzdata iproute2 \
    && useradd -d /home/container -m container

USER container
ENV  USER=container HOME=/home/container

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]