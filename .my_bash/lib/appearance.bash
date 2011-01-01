#!/bin/bash

# colored grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;33'

# colored ls
#export LSCOLORS='Gxfxcxdxdxegedabagacad'
if ! [ $(uname) = "Darwin" ]; then 
  eval `dircolors -b ~/DIR_COLORS`
fi

# Load the theme
if [[ $BASH_THEME ]]; then
    source "$BASH/themes/$BASH_THEME/$BASH_THEME.theme.bash"
fi

