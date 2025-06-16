# Use Ubuntu 22.04 as base image, matching Azure DevOps hosted agent images
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV AGENT_ALLOW_RUNASROOT=1

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
# Note: Uncomment the following lines if Docker CLI is needed
# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
#     && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
#     && apt-get update \
#     && apt-get install -y docker-ce-cli \
#     && rm -rf /var/lib/apt/lists/*

# Install Azure CLI - commented out due to network restrictions in CI
# In production environments, Azure CLI can be installed using:
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
# For now, skip Azure CLI installation to avoid build failures

# Create a user for the agent
RUN useradd -m -s /bin/bash azureuser \
    && usermod -aG sudo azureuser \
    && echo 'azureuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Download and install Azure DevOps Agent
ARG AGENT_VERSION=3.245.0
# Note: In a proper network environment, this would download the agent
# RUN mkdir -p /home/azureuser/azagent \
#     && cd /home/azureuser/azagent \
#     && curl -o vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz -L https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
#     && tar xzf ./vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
#     && rm vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
#     && chown -R azureuser:azureuser /home/azureuser/azagent

# For demonstration purposes, create the directory structure
RUN mkdir -p /home/azureuser/azagent \
    && chown -R azureuser:azureuser /home/azureuser/azagent

# Note: In a real deployment, you would need to:
# 1. Download the agent from https://vstsagentpackage.azureedge.net/agent/{version}/vsts-agent-linux-x64-{version}.tar.gz
# 2. Extract it to /home/azureuser/azagent
# 3. Run ./bin/installdependencies.sh

# Install agent dependencies (placeholder)
# RUN cd /home/azureuser/azagent && ./bin/installdependencies.sh

# Switch to azureuser
USER azureuser
WORKDIR /home/azureuser/azagent

# Copy entrypoint script
COPY --chown=azureuser:azureuser entrypoint.sh /home/azureuser/entrypoint.sh
RUN chmod +x /home/azureuser/entrypoint.sh

# Ensure Unix-style line endings for entrypoint.sh
RUN sed -i 's/\r$//' /home/azureuser/entrypoint.sh

ENTRYPOINT ["/home/azureuser/entrypoint.sh"]