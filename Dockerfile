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
    echo steam steam/question select "I AGREE" | debconf-set-selections
    echo steam steam/license note '' | debconf-set-selections
    add-apt-repository multiverse
    dpkg --add-architecture i386
    apt-get update
    apt-get upgrade -y
    apt-get autoremove -y
    apt-get install -y --no-install-recommends \
        ca-certificates \
        software-properties-common \
        python-software-properties \
        lib32gcc1-s1 \
        libstdc++6 \
        curl \
        wget \
        bsdtar \
        build-essential \
        steamcmd
    rm -rf /var/lib/apt/lists/*
    ln -sf /usr/games/steamcmd /usr/bin/steamcmd
EOT

# creating /home/steam/.steam to avoid two error messages on steamcmd start
ENV UID=1000 \
    GID=1000
RUN <<EOT 
    # configure steamcmd
    addgroup --gid $GID steam
    adduser --system --uid $UID --gid $GID --shell /bin/bash steam
    mkdir -p /home/steam/.steam
    runuser -u steam steamcmd +quit
    mkdir -p /starbound
    # Add initial require update flag
    touch /.update
EOT

EXPOSE 28015
EXPOSE 28016

WORKDIR /

COPY --chmod=777 start.sh /start.sh
COPY --chmod=777 update.sh /update.sh

VOLUME ["/starbound"]

ENV STEAM_LOGIN FALSE

ENV DEBIAN_FRONTEND newt

ENTRYPOINT ["./start.sh"]
