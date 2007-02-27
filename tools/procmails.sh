#!/bin/sh

#ORGMAIL=/var/mail/$LOGNAME
ORGMAIL=$HOME/Mail/vincent

if cd $HOME &&
    test -s $ORGMAIL &&
    lockfile -r0 -l1024 $ORGMAIL.lock 2>/dev/null
then
    trap "rm -f $ORGMAIL.lock" 1 2 3 13 15
    #umask 077
    #lockfile -l1024 -ml
    formail -s procmail < $ORGMAIL 
    #lockfile -mu
    rm -f $ORGMAIL.lock
fi
exit 0
