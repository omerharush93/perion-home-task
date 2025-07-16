#!/bin/bash

# Script to download the application from S3
# Fulfills Setup Requirements: "Create Git repository from source: s3://hello-world-node-docker/hello-world-node.tar.gz"

set -e

echo "📥 Downloading application from S3..."

# Create working directory
mkdir -p app
cd app

# Download the application from S3
echo "⬇️  Downloading hello-world-node.tar.gz..."
aws s3 cp s3://hello-world-node-docker/hello-world-node.tar.gz .

# Extract the application
echo "📦 Extracting the application..."
tar -xzf hello-world-node.tar.gz

# List contents
echo "📋 Directory contents:"
ls -la

# Initialize Git repository
echo "🔧 Initializing Git repository..."
git init
git add .
git commit -m "Initial commit: Hello World Node.js application from S3"

echo "✅ Application downloaded and prepared successfully!"
echo "📁 Directory is: $(pwd)" 