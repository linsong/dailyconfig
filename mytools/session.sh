#!/bin/sh -x

[ ! -z "$TMUX" ] && exit

# I alias this script to "session" in .profile and use it to reconnect to
# the main session (0) on my main tmux server.

TMUX="tmux -udLmain"

$TMUX has -t0 2>/dev/null || $TMUX -q start
exec $TMUX attach -d -t work
