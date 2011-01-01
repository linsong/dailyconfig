#!/bin/bash

if [ $(uname -s) = 'Cygwin' ];then
  alias xx='rxvt -geometry 125x44 -sr -sl 10000 -fg white -bg black -fn fixedsys -fb fixedsys -tn cygwin -cr SkyBlue -e /bin/bash --login -i&'
  alias pyhelp='s /cygdrive/c/Python24/Doc/ActivePython24.chm'
  alias wpython='/cygdrive/c/Python24/python.exe'
  alias e='explorer'
  alias makensis='c:/Program\ Files/NSIS/makensis.exe'
  alias pack='python /cygdrive/d/Project/utils/pack/pack.py'
  alias wrebase='C:/Program\ Files/Microsoft\ Visual\ Studio/VC98/Bin/rebase.exe'
  alias shutdown='reboot -s now'
  alias s='cygstart --maximize '
  alias start='cygstart '
  alias xwin='sh /usr/X11R6/bin/startxwin.sh'
  alias linuxcd='s /cygdrive/d/unzipped/ebook/linux/index.htm'
  alias bashhelp='s /cygdrive/d/unzipped/ebook/linux/OReilly\ -\ Learning\ the\ bash\ Shell\ -\ 2nd\ Edition.chm'

  # use the following command to start/stop PPPOE 
  # rasdial.exe entryname [username [password|*]] [/DOMAIN:domain]
  #   [/PHONE:phonenumber] [/CALLBACK:callbacknumber]
  #   [/PHONEBOOK:phonebookfile] [/PREFIXSUFFIX]
  # rasdial.exe [entryname] /DISCONNECT
  function pppoe()
  {
    if [ -n "$1" ]; then
      if [ "$1" = "on" ]; then
       if [ -n "$PPPOEPASSWD" ]; then
         PASSWD=$PPPOEPASSWD
       else
         read -s PASSWD 
         export PPPOEPASSWD=$PASSWD
       fi
       rasdial.exe adsl 100001267980 $PASSWD
      elif [ "$1" = "off" ]; then
       rasdial.exe /DISCONNECT
      else
        cat <<__END
  Usage: 
    pppoe [on]/[off]
  __END
      fi
     else
       cat <<__END
  Usage: 
    pppoe [on]/[off]
  __END
    fi
  }

  function desktop()
  {
    cd /cygdrive/c/Documents\ and\ Settings/$USER/
  }

fi
