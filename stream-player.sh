#!/bin/bash

# AceStream Terminal Player
# Simplified script to start AceStream and play streams directly in IINA

set -e

M3U_FILE="streams.m3u"
ACESTREAM_PORT="6878"
ACESTREAM_HOST="127.0.0.1"

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${BLUE}"
    echo "🎬 AceStream Terminal Player"
    echo "============================="
    echo -e "${NC}"
}

function check_dependencies() {
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        echo -e "${RED}[!] Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
    
    # Check if IINA is installed
    if ! ls /Applications/ | grep -qi IINA; then 
        echo -e "${RED}[!] IINA not found. Download it from https://iina.io${NC}"
        exit 1
    fi
    
    # Check if M3U file exists
    if [[ ! -f "$M3U_FILE" ]]; then
        echo -e "${RED}[!] $M3U_FILE not found in current directory${NC}"
        exit 1
    fi
}

function start_acestream() {
    echo -e "${YELLOW}[*] Checking AceStream status...${NC}"
    
    # Check if AceStream is already running
    if curl -s "http://${ACESTREAM_HOST}:${ACESTREAM_PORT}/webui/api/service?method=get_version" &> /dev/null; then
        echo -e "${GREEN}[✓] AceStream is already running${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}[*] Starting AceStream engine...${NC}"
    
    # Stop any existing container
    docker stop acestream-engine 2>/dev/null || true
    docker rm acestream-engine 2>/dev/null || true
    
    # Start AceStream container
    docker run -d --rm \
        --platform=linux/amd64 \
        -p ${ACESTREAM_PORT}:${ACESTREAM_PORT} \
        --name=acestream-engine \
        blaiseio/acelink:latest > /dev/null
    
    echo -e "${YELLOW}[*] Waiting for AceStream to be ready...${NC}"
    
    # Wait until AceStream server is ready
    local attempts=0
    local max_attempts=60
    while ! curl -s "http://${ACESTREAM_HOST}:${ACESTREAM_PORT}/webui/api/service?method=get_version" &> /dev/null; do
        if [[ $attempts -gt $max_attempts ]]; then
            echo -e "${RED}[!] Timeout waiting for AceStream to start${NC}"
            exit 1
        fi
        printf "."
        sleep 1
        ((attempts++))
    done
    
    echo ""
    echo -e "${GREEN}[✓] AceStream engine is ready!${NC}"
}

function parse_m3u() {
    local channels=()
    local titles=()
    local ids=()
    
    while IFS= read -r line; do
        if [[ $line == "#EXTINF:"* ]]; then
            # Extract title after the comma
            local title="${line#*,}"
            titles+=("$title")
        elif [[ $line == "http://localhost:6878/ace/getstream?id="* ]]; then
            # Extract ID from the URL
            local id="${line##*id=}"
            ids+=("$id")
        fi
    done < "$M3U_FILE"
    
    # Return arrays via global variables
    channel_titles=("${titles[@]}")
    channel_ids=("${ids[@]}")
}

function show_channel_menu() {
    echo ""
    echo -e "${BLUE}Available Streams:${NC}"
    echo "=================="
    
    for i in "${!channel_titles[@]}"; do
        echo -e "${YELLOW}$(($i + 1)).${NC} ${channel_titles[$i]}"
    done
    
    echo ""
    echo -e "${BLUE}Options:${NC}"
    echo "q) Quit"
    echo "r) Restart AceStream"
    echo ""
}

function play_channel() {
    local channel_id="$1"
    local channel_title="$2"
    
    echo -e "${YELLOW}[*] Starting stream: ${channel_title}${NC}"
    
    local stream_url="http://${ACESTREAM_HOST}:${ACESTREAM_PORT}/ace/getstream?id=${channel_id}"
    echo -e "${YELLOW}[*] Stream URL: ${stream_url}${NC}"
    
    # Open stream in IINA
    /Applications/IINA.app/Contents/MacOS/iina-cli "${stream_url}" &
    
    echo -e "${GREEN}[✓] Stream opened in IINA${NC}"
    echo -e "${BLUE}[*] Press Enter to return to menu...${NC}"
    read
}

function restart_acestream() {
    echo -e "${YELLOW}[*] Restarting AceStream...${NC}"
    docker stop acestream-engine 2>/dev/null || true
    docker rm acestream-engine 2>/dev/null || true
    start_acestream
}

function cleanup() {
    echo ""
    echo -e "${YELLOW}[*] Cleaning up...${NC}"
    docker stop acestream-engine 2>/dev/null || true
    docker rm acestream-engine 2>/dev/null || true
    echo -e "${GREEN}[✓] Cleanup complete${NC}"
}

# Main script
function main() {
    # Trap to cleanup on exit
    trap cleanup EXIT
    
    print_header
    check_dependencies
    start_acestream
    
    # Parse M3U file
    parse_m3u
    
    if [[ ${#channel_titles[@]} -eq 0 ]]; then
        echo -e "${RED}[!] No streams found in $M3U_FILE${NC}"
        exit 1
    fi
    
    # Main menu loop
    while true; do
        show_channel_menu
        
        read -p "Select stream number (1-${#channel_titles[@]}): " choice
        
        case $choice in
            [qQ])
                echo -e "${GREEN}[✓] Goodbye!${NC}"
                break
                ;;
            [rR])
                restart_acestream
                ;;
            [1-9]|[1-9][0-9])
                local index=$((choice - 1))
                if [[ $index -ge 0 && $index -lt ${#channel_titles[@]} ]]; then
                    play_channel "${channel_ids[$index]}" "${channel_titles[$index]}"
                else
                    echo -e "${RED}[!] Invalid choice: $choice${NC}"
                    echo -e "${BLUE}[*] Press Enter to continue...${NC}"
                    read
                fi
                ;;
            *)
                echo -e "${RED}[!] Invalid choice: $choice${NC}"
                echo -e "${BLUE}[*] Press Enter to continue...${NC}"
                read
                ;;
        esac
    done
}

# Run main function
main "$@"