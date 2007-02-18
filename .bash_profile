# ~/.bash_profile: executed by bash for login shells.

if [ -e /etc/bash.bashrc ] ; then
  source /etc/bash.bashrc
fi

# Set PATH so it includes user's private bin if it exists
# if [ -d ~/bin ] ; then
#   PATH="~/bin:${PATH}"
# fi

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

 if [ -e /sw/bin/init.sh ]; then 
     . /sw/bin/init.sh
 fi

if [ -f /sw/etc/bash_completion ]; then 
    . /sw/etc/bash_completion
fi

PATH=/opt/local/bin:$PATH
# for darwinports bash-completion
if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi

# use keychain to replace ssh-agent, because keychain can be used under both X window mode and console mode
KEYCHAIN_CMD=$(which keychain)
if [ -n $KEYCHAIN_CMD ]; then 
    $KEYCHAIN_CMD ~/.ssh/id_dsa 
    . ~/.keychain/$HOSTNAME-sh
fi

if [ -e ~/.bashrc ] ; then
  source ~/.bashrc
fi
