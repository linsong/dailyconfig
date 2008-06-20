#! /bin/bash
set -x 
ssh -v -N -L 8022:vincent:22 -L 8001:vincent:80 -L 8079:vincent:8079 -L 8078:vincent:8078 -L 8090:vincent:8090 -L  8097:vincent:8097 -L 8098:vincent:8098  -L 9280:vincent:9280 -L 8099:vincent:8099  -L 6667:irc.exoweb.net:6667 box
