# Use Ubuntu 22.04 as base image, matching GitHub's runner images
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_ALLOW_RUNASROOT=1

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    jq \
    sudo \
    ca-certificates \
    lsb-release \
    gnupg \
    software-properties-common \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (for building container images)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create a user for the runner
RUN useradd -m -s /bin/bash runner \
    && usermod -aG sudo runner \
    && echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Download and install GitHub Actions Runner
ARG RUNNER_VERSION=2.325.0
RUN mkdir -p /home/runner/actions-runner \
    && cd /home/runner/actions-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && chown -R runner:runner /home/runner/actions-runner

# Install runner dependencies
RUN cd /home/runner/actions-runner && ./bin/installdependencies.sh

# Switch to runner user
USER runner
WORKDIR /home/runner/actions-runner

# Copy entrypoint script
COPY --chown=runner:runner entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh

# Ensure Unix-style line endings for entrypoint.sh
RUN sed -i 's/\r$//' /home/runner/entrypoint.sh

ENTRYPOINT ["/home/runner/entrypoint.sh"]