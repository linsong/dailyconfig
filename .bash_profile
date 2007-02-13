# ~/.bash_profile: executed by bash for login shells.

PATH=/opt/local/bin:$PATH

if [ -e /etc/bash.bashrc ] ; then
  source /etc/bash.bashrc
fi

if [ -e ~/.bashrc ] ; then
  source ~/.bashrc
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

#f for darwinports bash-completion
if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi

# use keychain to replace ssh-agent, because keychain can be used under both X window mode and console mode
/usr/bin/keychain ~/.ssh/id_dsa 
. ~/.keychain/$HOSTNAME-sh
