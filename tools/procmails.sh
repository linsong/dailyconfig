#!/bin/sh

#ORGMAIL=/var/mail/$LOGNAME
ORGMAIL=$HOME/Mail/vincent

if cd $HOME &&
    test -s $ORGMAIL &&
    lockfile -r0 -l1024 .newmail.lock 2>/dev/null
then
    trap "rm -f .newmail.lock" 1 2 3 13 15
    umask 077
    lockfile -l1024 -ml
    cat $ORGMAIL >>.newmail &&
    cat /dev/null >$ORGMAIL
    lockfile -mu
    formail -s procmail <.newmail &&
    rm -f .newmail
    rm -f .newmail.lock
fi
exit 0
