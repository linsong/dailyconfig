#! /bin/bash
set -x 
ssh -v -N -L 8022:vincent:22 -L 8080:vincent:8080 -L 8079:vincent:8079 -L 8090:vincent:8090 -L 8007:vincent:8007 -L 8097:vincent:8097 -L 8098:vincent:8098 -L 8107:vincent:8107 -L 8091:vincent:8091 -L 8092:vincent:8092 -L 6667:irc.exoweb.net:6667 box
