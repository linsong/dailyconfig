#!/bin/sh -x

[ ! -z "$TMUX" ] && exit

monit

#TMUX="tmux -udLmain" # for v1.0- version 
TMUX="tmux -u" # use 'default' socket 

$TMUX has -t work 2>/dev/null || $TMUX -q start
#exec $TMUX attach -d -t work
exec $TMUX attach -t work # don't use '-d' if you want to multiuser can attach to the same session at the same time
