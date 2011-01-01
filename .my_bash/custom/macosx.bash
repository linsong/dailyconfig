#!/bin/bash

if [ $(uname) = "Darwin" ]; then 
  # ENV VARS 
  export JAVA_HOME='/Library/Java/Home'

  # make macports in higher priority
  export PATH=/opt/local/bin:$PATH

  # ALIAS
  alias gitx='/Applications/GitX.app/Contents/MacOS/GitX >/dev/null 2>&1'
  alias ls='ls -FG'  

  if [ -f /opt/local/sbin/bitlbee ] ; then 
      /opt/local/sbin/bitlbee -c $HOME/.bitlbee/bitlbee.conf 
  fi
  
  if [ -f /opt/local/bin/esd ]; then 
      /opt/local/bin/esd >/dev/null 2>&1 &
  fi
fi

