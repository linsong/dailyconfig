#!/bin/bash

export EDITOR=/opt/local/bin/vim
export VISUAL=/opt/local/bin/vim

# add ruby gems bin folder into path 
export PATH=~/.gem/ruby/1.8/bin:$PATH

# add MacTex path
export PATH=/usr/texbin:$PATH

# Set PATH so it includes user's private bin if it exists
 if [ -d ~/mytools ] ; then
   PATH=${PATH}:$HOME/mytools
 fi

# Set MANPATH so it includes users' private man if it exists
 if [ -d ~/man ]; then
   MANPATH="~/man:${MANPATH}"
 fi

# Set INFOPATH so it includes users' private info if it exists
 if [ -d ~/info ]; then
   INFOPATH="~/info:${INFOPATH}"
 fi
