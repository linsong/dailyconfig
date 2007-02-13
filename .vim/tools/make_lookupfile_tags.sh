#! /usr/bin/env bash

DEST_DIR=${1:=$(pwd)}

cd $DEST_DIR

(echo "!_TAG_FILE_SORTED    2   /2=foldcase/";
  find . \( -type d -iname ".svn" -prune \) -o -not -iregex '.*\.\(jar\|gif\|jpg\|class\|exe\|dll\|pdd\|sw[op]\|xls\|doc\|pdf\|zip\|tar\|ico\|ear\|war\|dat\|pyc\|swf\).*' -type f -printf "%f\t%p\t1\n") | \
 sort -f > ./filenametags

cd - 


