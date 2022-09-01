FROM ubuntu:22.04
MAINTAINER Urs Roesch <github@bun.ch>

#VERSION 1.2.2
ENV container docker
ENV DEBIAN_FRONTEND=noninteractive
ENV CODENAME jammy

# install base tools for docker build
RUN apt-get update \
    && apt-get install -y \
       ansible \
       bridge-utils \
       curl \
       dnsmasq \
       file \
       genisoimage \
       git \
       gosu \
       gpg \
       iproute2 \
       jq \
       p7zip-full \
       qemu-kvm \
       rake \
       software-properties-common \
       websockify \
       xorriso \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && find /var/cache/apt/archives -type f -delete

# install latest packer from hashicorp
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com ${CODENAME} main" \
    && apt-get update \
    && apt-get -y install packer \
    && apt-get -y autoremove \
    && apt-get -y autoclean \
    && find /var/cache/apt/archives -type f -delete

# install novnc from git
RUN cd /usr/local && \
    git clone https://github.com/novnc/noVNC.git novnc && \
    chmod 755 novnc/utils/novnc_proxy && \
    cd /usr/local/bin && \
    ln -s ../novnc/utils/novnc_proxy

# Add RSA keys to ssh_config
# See: https://askubuntu.com/questions/1409105
RUN sed -i \
    -e '/Host \*/a\    PubkeyAcceptedKeyTypes +ssh-rsa' \
    -e '/Host \*/a\    HostkeyAlgorithms +ssh-rsa' \
    /etc/ssh/ssh_config

# copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

# copy the novnc start script
COPY vnc-proxy.sh /vnc-proxy.sh
RUN chmod u+x /vnc-proxy.sh

EXPOSE 5900-5999

ENTRYPOINT ["/entrypoint.sh"]
