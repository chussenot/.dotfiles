#!/bin/bash

# Dotfiles Testing Sandbox Setup
# This script creates a Docker container for testing dotfiles

set -e

CONTAINER_NAME="dotfiles-test"
DOCKER_IMAGE="ubuntu:22.04"
TEST_USER="testuser"

echo "🚀 Setting up dotfiles testing sandbox..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Clean up existing container if it exists
echo "🧹 Cleaning up existing test container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Pull the Ubuntu image
echo "📦 Pulling Ubuntu 22.04 image..."
docker pull $DOCKER_IMAGE

# Create and start the container
echo "🔧 Creating test container..."
docker run -d \
    --name $CONTAINER_NAME \
    --hostname dotfiles-test \
    -v "$(pwd):/dotfiles:ro" \
    -v "$(pwd)/test-sandbox/scripts:/scripts:ro" \
    $DOCKER_IMAGE \
    tail -f /dev/null

# Wait for container to be ready
sleep 2

# Install packages and setup user
echo "📦 Installing packages in container..."
docker exec $CONTAINER_NAME bash -c "
    apt-get update &&
    apt-get install -y curl git sudo zsh tmux python3 python3-pip vim nano neovim direnv &&
    useradd -m -s /bin/zsh $TEST_USER &&
    echo '$TEST_USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&
    chown -R $TEST_USER:$TEST_USER /home/$TEST_USER
"

# Copy dotfiles to container
echo "📁 Copying dotfiles to container..."
docker exec $CONTAINER_NAME bash -c "
    cp -r /dotfiles /home/$TEST_USER/.dotfiles &&
    chown -R $TEST_USER:$TEST_USER /home/$TEST_USER/.dotfiles
"

echo "✅ Testing sandbox setup complete!"
echo ""
echo "📋 Available commands:"
echo "  ./test-sandbox/test.sh          - Run automated test"
echo "  ./test-sandbox/interactive.sh   - Start interactive session"
echo "  ./test-sandbox/cleanup.sh       - Clean up test environment" 