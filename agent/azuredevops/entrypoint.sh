#!/bin/bash

set -e

# Function to cleanup agent on exit
cleanup() {
    echo "Removing Azure DevOps agent..."
    if [ -f .agent ]; then
        ./config.sh remove --unattended --auth pat --token "${AZP_TOKEN}"
    fi
}

# Trap cleanup function on exit
trap cleanup EXIT

# Configure the Azure DevOps agent
echo "Configuring Azure DevOps Agent..."
# Echo out the variables for debugging
echo "AZP_URL=${AZP_URL}"
echo "AZP_TOKEN=***"  # Don't expose the token in logs
echo "AZP_AGENT_NAME=${AZP_AGENT_NAME:-$(hostname)}"
echo "AZP_POOL=${AZP_POOL:-Default}"
echo "AZP_WORK=${AZP_WORK:-_work}"

# Validate required environment variables
if [ -z "${AZP_URL}" ]; then
    echo "Error: AZP_URL environment variable is required"
    exit 1
fi

if [ -z "${AZP_TOKEN}" ]; then
    echo "Error: AZP_TOKEN environment variable is required"
    exit 1
fi

# Configure the agent
./config.sh \
    --unattended \
    --url "${AZP_URL}" \
    --auth pat \
    --token "${AZP_TOKEN}" \
    --pool "${AZP_POOL:-Default}" \
    --agent "${AZP_AGENT_NAME:-$(hostname)}" \
    --work "${AZP_WORK:-_work}" \
    --replace

# Start the agent
echo "Starting Azure DevOps Agent..."
./run.sh