#! /bin/bash
### by this script, we can automate the process of launching the x11vnc server remotely 
### and launch the xvncviewer locally at the same time. actually, this script comes from 
### [http://www.karlrunge.com/x11vnc/#faq], the homesite of x11vnc, it really makes life easier! :)
### 			- Sun Nov  6 00:56:11     2005
### this script has one tip: how to run two application at the same time, use subshell and exec command
### 			- Sun Nov  6 01:21:42     2005

set -vx 

gateway="box.exoweb.net"
gateway_user="vincent"
host="vincent.lan.exoweb.net"
host_user="vincent"

if [ `uname -o` = 'Cygwin' ];then
	client_cmd="/home/$(whoami)/tools/tightvnc/vncviewer.exe /8bit /compresslevel 1 /quality 0 localhost"
else
	client_cmd="vncviewer -encodings \"copyrect tight zrle zlib hextile\" \
    localhost:0 </dev/null >/dev/null"
fi

cmd="sudo x11vnc -auth /var/lib/gdm/:0.Xauth -display :0"

## Need to sleep long enough for all of the passwords and x11vnc to start up.
(sleep 10; $client_cmd ) &

#TODO: how to run x11vnc without root permission .
exec ssh -t -L 5900:$host:5900 $gateway_user@$gateway \
	 ssh $host_user@$host $cmd


### The *original* script comes from http://www.karlrunge.com/x11vnc/#faq
##!/bin/sh
##
#gateway="example.com"com# or "user@example.com"
#host="labyrinth"labyrinth# or "user@hostname"
#user="kyle"
#
## Need to sleep long enough for all of the passwords and x11vnc to start up.
## The </dev/null below makes the vncviewer prompt for passwd via popup window. 
##
#(sleep 10; vncviewer -encodings "copyrect tight zrle zlib hextile" \
#    localhost:0 </dev/null >/dev/null) &
#
## Chain the vnc connection thru 2 ssh's, and connect x11vnc to user's display:
##
#exec /usr/bin/ssh -t -L 5900:localhost:5900 $gateway \
#     /usr/bin/ssh -t -L 5900:localhost:5900 $host \
#	      sudo /usr/bin/x11vnc -localhost -auth /home/$user/.Xauthority \
#		           -rfbauth .vnc/passwd -display :0
#
