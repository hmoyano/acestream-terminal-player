#!/bin/bash

# Based on the working script from play.md
# Simple script to play Acestream IDs with IINA

function helptext {
    echo "USAGE: ./play-stream.sh <Acestream ID>"
    echo "Example: ./play-stream.sh b08e158ea3f5c72084f5ff8e3c30ca2e4d1ff6d1"
}

[ -z "$1" ] && helptext && exit 0

if ! ls /Applications/ | grep -qi IINA; then 
    echo "[!] Error! IINA not found, get it at https://iina.io"
    exit 1
fi

# Remove "acestream://" from arg if found at the beginning
full=$1
prefix="acestream://"
hash=${full/#$prefix}

port="6878"
ip_address="127.0.0.1"

# Check if Ace Stream server is running
if ! curl "http://${ip_address}:${port}/webui/api/service?method=get_version" &> /dev/null; then
    echo "[!] Ace Stream server not running. Start it with:"
    echo "docker-compose up -d acestream"
    exit 1
fi

echo "[*] Ace Stream server is running"

# Open stream in IINA using the correct command from the script
stream="http://$ip_address:${port}/ace/getstream?id=${hash}"
echo "[*] Opening stream: $stream"

# Use iina-cli as shown in the working script
/Applications/IINA.app/Contents/MacOS/iina-cli "${stream}"