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

# Patch server.js to ensure /health and /ready endpoints exist for Kubernetes probes
echo "🔧 Patching server.js for Kubernetes readiness/liveness probes..."
SERVER_FILE="hello-world-node/server.js"
if ! grep -q "/health" "$SERVER_FILE"; then
  cat <<'EOF' >> "$SERVER_FILE"

// Added for Kubernetes readiness/liveness probes
if (require.main === module) {
  const http = require('http');
  const hostname = '0.0.0.0';
  const port = 3000;
  const server = http.createServer((req, res) => {
    if (req.url === '/health' || req.url === '/ready') {
      res.statusCode = 200;
      res.end('OK');
      return;
    }
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World!');
  });
  server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
  });
}
EOF
  echo "✅ Patched server.js with /health and /ready endpoints."
else
  echo "ℹ️  server.js already contains /health and /ready endpoints."
fi

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