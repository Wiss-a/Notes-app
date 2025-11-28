FROM ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Installer Ansible et les dépendances
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
    && rm -rf /var/lib/apt/lists/*

# Installer les collections Ansible nécessaires
RUN ansible-galaxy collection install kubernetes.core
RUN ansible-galaxy collection install community.docker

# Configuration SSH pour éviter la vérification des clés
RUN mkdir -p /root/.ssh && \
    echo "Host *" > /root/.ssh/config && \
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config && \
    echo "    UserKnownHostsFile=/dev/null" >> /root/.ssh/config && \
    chmod 600 /root/.ssh/config

# Définir le répertoire de travail
WORKDIR /ansible

# Copier les fichiers Ansible (sera fait via volume en dev)
# COPY ansible/ /ansible/

# Garder le conteneur actif
CMD ["tail", "-f", "/dev/null"]