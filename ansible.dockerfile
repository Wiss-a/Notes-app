FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Installer Ansible et outils
RUN apt-get update && apt-get install -y \
    ansible \
    sshpass \
    openssh-client \
    python3 \
    python3-pip \
    git \
    curl \
    vim \
    net-tools \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Installer les modules Python pour Ansible
RUN pip3 install --no-cache-dir \
    kubernetes \
    docker \
    openshift \
    pyyaml

# Installer collections Ansible
RUN ansible-galaxy collection install kubernetes.core && \
    ansible-galaxy collection install community.docker && \
    ansible-galaxy collection install community.general

# Configuration SSH
RUN mkdir -p /root/.ssh && \
    echo "Host *" > /root/.ssh/config && \
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config && \
    echo "    UserKnownHostsFile=/dev/null" >> /root/.ssh/config && \
    chmod 600 /root/.ssh/config

WORKDIR /ansible

CMD ["tail", "-f", "/dev/null"]