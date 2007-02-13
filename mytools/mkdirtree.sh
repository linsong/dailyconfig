#! /bin/sh 

#function usage()
#{
  #echo "Usage: ";
  #echo "       $0 <DestPath> [SrcPath]  ";
#}

SRCDIR=${1:?"You MUST specify a directory"}
DESTDIR=${2:-"."}


if [ -d $SRCDIR ] && [ -d $DESTDIR ] ; then
	find ${SRCDIR} -type d | gawk 'NR==1 {len=length()} NR!=1 {print substr($0,len+1)}' \
														 | sed -e "s/\(.*\)/$DESTDIR\/\1/" \
														 | xargs mkdir -p
else
    echo "Usage: ";
    echo "       $0 <SrcDir> [DestDir]  ";
	exit 1
fi 

