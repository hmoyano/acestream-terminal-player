#!/bin/bash

echo "Starting Ace Stream engine..."

# Stop any existing container
docker stop acestream-engine 2>/dev/null || true
docker rm acestream-engine 2>/dev/null || true

# Start with the exact same parameters as the working script
docker run -d --rm \
  --platform=linux/amd64 \
  -p 6878:6878 \
  --name=acestream-engine \
  blaiseio/acelink:1.3.0

echo "Waiting for Ace Stream to be ready..."

# Wait until Ace Stream server runs (like in the working script)
until curl "http://127.0.0.1:6878/webui/api/service?method=get_version" &> /dev/null; do
    printf "."
    sleep 0.5
done

echo ""
echo "✅ Ace Stream engine is ready!"
echo "🎬 Now you can:"
echo "  1. Drag football-streams.m3u into IINA"
echo "  2. Or run: ./play-stream.sh [acestream-id]"