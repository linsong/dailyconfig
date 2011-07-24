#!/bin/bash

# Path to the my bash configuration
export BASH=$HOME/.my_bash

# Lock and Load a custom theme file
# location /.my_bash/themes/
export BASH_THEME='default'

## Set my editor and git editor
#export EDITOR="/opt/local/bin/vi"

unset MAILCHECK

export SSH_KEY_IN_AGENT="$HOME/.ssh/id_dsa"

# Load My Bash 
source $BASH/my_bash.sh

fortune | cowsay 
