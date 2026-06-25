#!/bin/bash
set -euo pipefail

echo "Building ttyd_connect image..."

if [ ! -f "host_config" ]; then
  echo "host_config not found; copying host_config.example"
  cp host_config.example host_config
fi

docker build -t ttyd_connect:latest .
echo "Build complete: ttyd_connect:latest"
echo "Run with: docker compose up -d"
echo "Mount your private key at run time (never commit key.pem)."
