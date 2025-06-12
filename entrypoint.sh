#!/bin/bash

set -e

# Function to cleanup runner on exit
cleanup() {
    echo "Removing runner..."
    if [ -f .runner ]; then
        ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
    fi
}

# Trap cleanup function on exit
trap cleanup EXIT

# Configure the runner
echo "Configuring GitHub Actions Runner..."
./config.sh \
    --url "${GITHUB_REPOSITORY_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME:-$(hostname)}" \
    --work "${RUNNER_WORKDIR:-_work}" \
    --labels "${RUNNER_LABELS:-azure,container-app}" \
    --unattended \
    --replace

# Start the runner
echo "Starting GitHub Actions Runner..."
./run.sh