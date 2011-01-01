#!/bin/bash

# List directory contents
alias sl='ls -lt'
alias ls='ls -FG'        # Compact view, show colors
#alias ls='ls -F --color=tty --show-control-chars'
alias la='ls -AF'       # Compact view, show hidden
alias ll='ls -al'
alias l='ls -a'
alias l1='ls -1'
alias lh='ls -lh'

alias c='clear'

alias edit="$EDITOR"
alias page="$PAGER"

#alias q="exit"

alias irc="$IRC_CLIENT"

alias rb="ruby"

# Pianobar can be found here: http://github.com/PromyLOPh/pianobar/

alias piano="pianobar"

alias ..='cd ..'        # Go up one directory
alias ...='cd ../..'    # Go up two directories
alias -- -="cd -"       # Go back

alias wp='cd $PROJECT_DIR'

# Shell History
alias h='history'

# Tree
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

# Directory
alias	md='mkdir -p'
alias	rd=rmdir
alias d='dirs -v'

alias lsd='find . -type d -maxdepth 1'

alias dir='ls --color=auto --format=vertical'

alias less='less -r'

# rxvt
alias xx='rxvt -geometry 125x44 -sr -sl 10000 -fg white -bg black -fb fixedsys -fn fixedsys -tn rxvt -cr SkyBlue -e /bin/bash --login -i&'

# use the sed command to convert file format between Unix an DOS 
# sed -e 's/.$//' mydos.txt > myunix.txt
# and I make some alias to make thinks easier
alias dos2unix="sed -e 's/.$//'"
alias unix2dos="sed -e 's/$/\r/'"

alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"' 

function aliases-help() {
  echo "Generic Alias Usage"
  echo
  echo "  sl     = ls"
  echo "  ls     = ls -G"
  echo "  la     = ls -AF"
  echo "  ll     = ls -al"
  echo "  l      = ls -a"
  echo "  c/k    = clear"
  echo "  ..     = cd .."
  echo "  ...    = cd ../.."
  echo "  -      = cd -"
  echo "  h      = history"
  echo "  md     = mkdir -p"
  echo "  rd     = rmdir"
  echo "  d      = dirs -v"
  echo "  editor = $EDITOR"
  echo "  pager  = $PAGER"
  echo "  piano  = pianobar"
  echo "  q      = exit"
  echo "  irc    = $IRC_CLIENT"
  echo 
}
