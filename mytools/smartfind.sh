#!/bin/bash
# smartfind.sh -- created 2007-07-26, Vincent Wang
# @Last Change: 2007-07-26
# @Revision:    0.1
### How to use:
###   $ ln -s smartfind.sh pyfind
###   $ pyfind -inH blahblah   # search string 'blahbalh' from all python files

BASE_NAME=$(basename "$0")
EXT_NAME=${BASE_NAME/find/}

if [ -n "${EXT_NAME}" ]; then 
    #find . \( -type d -iname "lib" -prune \) -o \( -type d -iname "zope" -prune \) -o -type f -iname "*.py"  | xargs grep $*
    find . \( -type d -iname "lib" -prune \) -o \( -type d -iname "zope" -prune \) -o -type f -iname "*.$EXT_NAME"  | xargs grep $*
fi

# vi: 
