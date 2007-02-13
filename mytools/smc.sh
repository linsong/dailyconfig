#!/bin/bash
#===============================================================================
#
#          FILE:  smc.sh
# 
#         USAGE:  ./smc.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:   (), 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  11/07/2006 03:38:41 PM CST
#      REVISION:  ---
#===============================================================================
function foo()
{
     local -a COLOR_ARRAY
     COLOR_ARRAY=('[31;40m'
        '[32;40m'
        '[33;40m'
        '[34;40m'
        '[35;40m'
        '[36;40m'
        '[31;47m'
        '[32;47m'
        '[33;47m'
        '[34;47m'
        '[35;47m'
        '[36;47m'
     )
     SED_SUBSTITUTE_OPT='g'
     while getopts ":i" opt; do
         case $opt in 
             i  ) SED_SUBSTITUTE_OPT=${SED_SUBSTITUTE_OPT}i;;
             \? ) echo "$0 : Colorize specified word of output."
                  echo "     Usage: $0 [-i] [-I] keywords..."
                  echo "      -i: ignore case               "
                  echo "      -I: case sensitive            "
             exit 0
         esac
         shift
     done

     for i in $(seq $#); do 
         COLOR_ARRAY_INDEX=$(((i-1)%${#COLOR_ARRAY}))
         SED_SCRIPT=$SED_SCRIPT"s/\($1\)/${COLOR_ARRAY[$COLOR_ARRAY_INDEX]}\1[m/$SED_SUBSTITUTE_OPT
         "
         shift
     done
     echo ${SED_SCRIPT:?'You must give me at least one keyword to highlight'} > /dev/null
     sed -u -e "$SED_SCRIPT"

}
 
foo $*
