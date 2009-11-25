#!/bin/sh -x

[ ! -z "$TMUX" ] && exit

# I alias this script to "session" in .profile and use it to reconnect to
# the main session (0) on my main tmux server.

#TMUX="tmux -udLmain" # for v1.0- version 
TMUX="tmux -uL main"

$TMUX has -t work 2>/dev/null || $TMUX -q start
#exec $TMUX attach -d -t work
exec $TMUX attach -t work # don't use '-d' if you want to multiuser can attach to the same session at the same time
