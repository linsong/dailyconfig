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

###########################################
### Settings for Fink
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

 if [ -d /opt/local/share/man ]; then
   MANPATH="/opt/local/share/man:${MANPATH}"
 fi

 if [ -d /opt/local/share/info ]; then
   INFOPATH="/opt/local/share/info:${INFOPATH}"
 fi

 if [ -d /opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin ]; then
    PATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin:${PATH}
 fi

KEYCHAIN_CMD=$(which keychain)
if [ -n "$KEYCHAIN_CMD" ]; then 
    $KEYCHAIN_CMD ~/.ssh/specific-key/id_dsa
    . ~/.keychain/$HOSTNAME-sh
fi

if [ -e ~/.bashrc ] ; then
  source ~/.bashrc
fi

# start to fetch mails 
# NOTE: we need to config fetchmail to run in daemon mode, 
#       then it does not matter if we call this multiple times
#if [ -z "$(pgrep -u $LOGNAME fetchmail)" ]; then 
#    fetchmail --nodetach >/dev/null 
#fi

if [ $(uname) == 'Darwin' ]; then
    if [ -e ~/.macrc ]; then
        source ~/.macrc
    fi
fi

case $(hostname) in 
    nordicserver | vincent | box | forge)
        if [ -e ~/.exowebrc ] ; then
            source ~/.exowebrc
        fi
        ;;
    *)
        ;;
esac


## NOT DONE YET
## check current environment and set up relevant env virables
#ASPIRE=10.2.19.201
#ZAX=192.168.1.11
#HOME=192.168.0.1

#ping -c 0 -t 1 $ASPIRE
#if [ "$?" -ne "0" ]; then 
    #export LOCATION='ASPIRE'
#else
    #ping -c 0 -t 1 $ZAX
    #if [ "$?" -ne "0" ]; then
        #export LOCATION='ZAX'
    #else
        #ping -c 0 -t 1 $HOME
        #if [ "$?" -ne "0" ]; then
            #export LOCATION='HOME'
        #fi
     #fi
#fi

fortune | cowsay 
