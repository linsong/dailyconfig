#! /bin/bash

set -x 

BACKUPDIR=/home/vincent/backup/`date +%Y-%m-%d`
SVNDB="/sandbox/mysvnbase"
#SVNDB="/sandbox/iss /sandbox/mysvnbase"
SVN_HOTBACKUP=/usr/lib/subversion/hot-backup.py

if [ ! -e $BACKUPDIR ]; then 
	mkdir -p $BACKUPDIR
fi

for dbpath in $SVNDB; do 
	dbname=`basename $dbpath`
	$SVN_HOTBACKUP $dbpath $BACKUPDIR 
done

for dir in $BACKUPDIR/*; do 
    if [ -d $dir ]; then
        tar -cjf $dir.tar.bz2 $dir && rm -rf $dir
    fi
done

#svnadmin hotcopy /sandbox/iss iss && tar -cjf iss.tar.bz2 iss && rm -rf iss
#svnadmin hotcopy /home/vincent/sandbox/mysvnbase mysvnbase && tar -cjf mysvnbase.tar.bz2 mysvnbase && rm -rf mysvnbase

