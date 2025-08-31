# AceStream Terminal Player

A simplified terminal-based application for streaming content using AceStream and IINA.

## Prerequisites

- Docker ([Download here](https://www.docker.com))
- IINA player ([Download here](https://iina.io))

## Setup

1. Create your own `streams.m3u` file with your AceStream IDs (see format below)
2. Run the application

```bash
# Run the streaming application
./stream-player.sh
```

## M3U File Format

Create a `streams.m3u` file in the project directory with your own AceStream IDs. The format should be:

```m3u
#EXTM3U
#EXTINF:-1,Channel Name Here
http://localhost:6878/ace/getstream?id=YOUR_ACESTREAM_ID_HERE
#EXTINF:-1,Another Channel Name
http://localhost:6878/ace/getstream?id=ANOTHER_ACESTREAM_ID_HERE
```

### Example:
```m3u
#EXTM3U
#EXTINF:-1,Sports Channel HD
http://localhost:6878/ace/getstream?id=b08e158ea3f5c72084f5ff8e3c30ca2e4d1ff6d1
#EXTINF:-1,Movie Channel 1080p
http://localhost:6878/ace/getstream?id=94d34491106e00394835c8cb68aa94481339b53f
#EXTINF:-1,News Channel
http://localhost:6878/ace/getstream?id=1bc437bce57b4b0450f6d1f8d818b7e97000745e
```

**Important Notes:**
- Replace `YOUR_ACESTREAM_ID_HERE` with actual AceStream content IDs
- You must provide your own content IDs - they are not included in this repository
- Each channel needs exactly two lines: `#EXTINF:-1,Channel Name` followed by the stream URL
- The stream URL format is always `http://localhost:6878/ace/getstream?id=ACESTREAM_ID`

## What it does

1. **Starts AceStream engine** in Docker automatically
2. **Waits for it to be ready** (shows progress dots)
3. **Displays channel menu** from `streams.m3u`
4. **Launches IINA** with your selected stream
5. **Cleans up** Docker containers on exit

## Files

- `stream-player.sh` - Main terminal application
- `streams.m3u` - Your channel list with AceStream IDs (you create this)
- `docker-compose.yml` - AceStream engine configuration
- `play-stream.sh` - Direct stream player (optional)
- `start-acestream.sh` - Manual AceStream starter (optional)

## Usage

### Interactive Menu
```bash
./stream-player.sh
```
- Select channel by number
- Press 'q' to quit
- Press 'r' to restart AceStream

### Direct Stream
```bash
./play-stream.sh <acestream-id>
```

### Manual Docker Control
```bash
# Start AceStream only
./start-acestream.sh

# Or use docker-compose
docker-compose up -d acestream
```

## Features

- ✅ No web browser needed
- ✅ Automatic Docker management  
- ✅ Interactive channel selection
- ✅ Direct IINA integration
- ✅ Smart error handling
- ✅ Clean exit with container cleanup
- ✅ Generic - works for any AceStream content (sports, movies, etc.)
