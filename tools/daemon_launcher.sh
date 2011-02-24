#!/bin/bash -xv

basename=$(basename $2)

HOME=/Users/vincent
mkdir -p $HOME/.pids

case $1 in
   start)
      echo $$ > $HOME/.pids/$basename.pid ;
      exec 2>&1 $2 1>/tmp/$basename.log
      ;;
    stop)  
      kill `cat $HOME/.pids/$basename.pid` ;
      rm $HOME/.pids/$basename.pid
      ;;
    *)  
      echo "usage: daemon_launcher {start|stop} daemon_tool_name" ;;
esac
exit 0
