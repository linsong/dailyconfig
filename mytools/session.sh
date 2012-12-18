#! /bin/bash

tmux start-server 

session=${1:-base}
if ! $(tmux has-session -t $session ); then 
  env TMUX= tmux start-server \; source-file $HOME/.tmux/profiles/$session
fi 

if [ -z $TMUX ]; then 
  tmux -u attach-session -t $session
else
  tmux -u switch-client -t $session
fi
