I would like to create a web-app where watch football or something that could work with an Ace Stream engine.

I already have Docker and I found this repo https://github.com/blaise-io/acelink but i don't want to install Ace Link because maybe it's malicious software (i don't know how to check this but the macbook warn me after install and try to open)

If you see his README.md file you will see that it says

Ace Stream server only

If you just want to run the AceStream engine, you can do so without Ace Link:

docker run --platform=linux/amd64 --rm -p 6878:6878 blaiseio/acelink
# now open http://<network ip>:6878/ace/getstream?id=<acestream id>
# or http://<network ip>:6878/ace/getstream?infohash=<magnet uri> in a player
If you want to use a custom acestream.conf:

docker run --platform=linux/amd64 --rm -p 6878:6878 -v "$(pwd)/acestream.conf:/opt/acestream/acestream.conf" blaiseio/acelink


So I think that maybe we can create something good.

I have the id's that I usually run in the file "ids_completos_2025.m3u"
