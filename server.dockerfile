FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ============================================
# PARTIE 1: Installation des dépendances système
# ============================================
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    vim \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    net-tools \
    iputils-ping \
    jq \
    unzip \
    conntrack \
    socat \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# PARTIE 2: Configuration SSH
# ============================================
RUN mkdir -p /var/run/sshd && \
    echo 'root:ansible' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# ============================================
# PARTIE 3: Installation de Docker
# ============================================
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# PARTIE 4: Installation de kubectl
# ============================================
RUN curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl && \
    kubectl version --client

# ============================================
# PARTIE 5: Installation de Minikube
# ============================================
RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    chmod +x minikube-linux-amd64 && \
    mv minikube-linux-amd64 /usr/local/bin/minikube && \
    minikube version

# ============================================
# PARTIE 6: Installation de Terraform
# ============================================
RUN wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip && \
    unzip terraform_1.6.6_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.6.6_linux_amd64.zip && \
    terraform version

# ============================================
# PARTIE 7: Installation de Helm
# ============================================
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    helm version

# ============================================
# PARTIE 8: Créer utilisateur ansible
# ============================================
RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible:ansible' | chpasswd && \
    usermod -aG sudo,docker ansible && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# ============================================
# PARTIE 9: Configuration de l'environnement
# ============================================
RUN mkdir -p /opt/notesapp/{terraform,scripts,app} && \
    chown -R ansible:ansible /opt/notesapp

# Variables d'environnement
ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /opt/notesapp

EXPOSE 22

# ============================================
# PARTIE 10: Script de démarrage
# ============================================
RUN echo '#!/bin/bash\n\
echo "Starting Docker service..."\n\
service docker start\n\
sleep 5\n\
echo "Docker service started"\n\
echo "Starting SSH service..."\n\
/usr/sbin/sshd -D' > /start.sh && \
chmod +x /start.sh

CMD ["/start.sh"]