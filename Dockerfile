FROM ubuntu:22.04

LABEL \
    org.opencontainers.image.authors="Morgyn, zokradonh <az@zok.xyz>" \
    org.opencontainers.image.title="Starbound dedicated server" \
    org.opencontainers.image.description="Starbound server image without persistent Steam credentials" \
    org.opencontainers.image.url="https://github.com/zokradonh/docker-starbound" \
    org.opencontainers.image.source="https://github.com/zokradonh/docker-starbound"

ENV LC_ALL en_US.UTF-8 
RUN locale-gen en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LANG en_US.UTF-8  

ENV DEBIAN_FRONTEND noninteractive

RUN <<EOT
    apt-get update
    apt-get upgrade -y
    apt-get autoremove -y
    apt-get install -y --no-install-recommends \
        ca-certificates \
        software-properties-common \
        python-software-properties \
        lib32gcc1 \
        libstdc++6 \
        curl \
        wget \
        bsdtar \
        build-essential
    rm -rf /var/lib/apt/lists/*
EOT

USER root

RUN mkdir -p /steamcmd
RUN mkdir -p /starbound

RUN <<EOT
    cd /steamcmd
	wget -o /tmp/steamcmd.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz
	tar zxvf steamcmd_linux.tar.gz
	rm steamcmd_linux.tar.gz
    chmod +x ./steamcmd.sh
EOT

EXPOSE 28015
EXPOSE 28016

WORKDIR /

ADD start.sh /start.sh
ADD update.sh /update.sh

# Add initial require update flag
ADD .update /.update

VOLUME ["/starbound"]

ENV STEAM_LOGIN FALSE

ENV DEBIAN_FRONTEND newt

ENTRYPOINT ["./start.sh"]
