#!/bin/bash
# Initialize My Bash

# Reload Library
alias reload='source ~/.bash_profile'

# Load the framework

# Load colors first so they can be use in base theme
source "${BASH}/themes/colors.theme.bash"
source "${BASH}/themes/base.theme.bash"

# Library
LIB="${BASH}/lib/*.bash"
for config_file in $LIB
do
  source $config_file
done

# Tab Completion
## Load system bash completion first
for config_file in  /etc/bash_completion /opt/local/etc/bash_completion
do
  [ -e "$config_file" ] && source $config_file
done

## Load custom completion
COMPLETION="${BASH}/completion/*.bash"
for config_file in $COMPLETION
do
  [ -e "$config_file" ] && source $config_file
done

# Plugins
PLUGINS="${BASH}/plugins/*.bash"
for config_file in $PLUGINS
do
  source $config_file
done

# Aliases
FUNCTIONS="${BASH}/aliases/*.bash"
for config_file in $FUNCTIONS
do
  source $config_file
done

# Custom
CUSTOM="${BASH}/custom/*.bash"
for config_file in $CUSTOM
do
  source $config_file
done


unset config_file
if [[ $PROMPT ]]; then
    export PS1=$PROMPT
fi

# Adding Support for other OSes
PREVIEW="less"
[ -s /usr/bin/gloobus-preview ] && PREVIEW="gloobus-preview"
[ -s /Applications/Preview.app ] && PREVIEW="/Applications/Preview.app"

#
# Custom Help

