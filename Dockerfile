FROM tsl0922/ttyd:latest

RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    rsync \
    curl \
    wget \
    vim \
    nano \
    git \
    htop \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

ENV USERNAME=admin
ENV PASSWORD=changeme

COPY host_config /root/.ssh/config
RUN chmod 644 /root/.ssh/config

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /root

EXPOSE 7681

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
