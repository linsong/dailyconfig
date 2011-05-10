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

# keys used in seravia
export SSH_KEY_IN_AGENT="$HOME/.ssh/id_dsa_deployer_git $HOME/.ssh/specific-key/id_dsa_seravia_production $HOME/.ssh/specific-key/id_dsa_seravia_office"

# Load My Bash 
source $BASH/my_bash.sh

fortune | cowsay 
