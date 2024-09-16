ARG DOCKER_IMAGE_BASE
FROM ${DOCKER_IMAGE_BASE}
ENV RUNTIME_DEPS \
    supervisor \
    nano \
    curl \
    apt-transport-https \
    ca-certificates \
    pwgen \
    wget \
    dnsutils \
    unzip \
    net-tools  \
    curl \
    gnupg2 \
    lsb-release \
    tzdata \
    supervisor \
    inetutils-ping \
    bash \
    git \
    rsync \
    sshpass \
    cron \
    libpcre3 \
    redis-tools \
    iproute2 \
    ssh \
    iptables 

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ "UTC"
RUN apt update && apt install -y ${RUNTIME_DEPS} ${BUILD_DEPS}