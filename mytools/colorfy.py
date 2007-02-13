#! /usr/bin/env python
""" This tools can make the specified word colorful. 
    And this will make screen output more readable. 
"""

import os
import sys
import getopt
import re

fmters = [
        '[31;40;1;5m%s[m',
        '[32;40;1;5m%s[m',
        '[33;40;1;5m%s[m',
        '[34;40;1;5m%s[m',
        '[35;40;1;5m%s[m'
        ]
        
def Usage():
    print """ 
  Colorize the given words of the input stream.
  Usage: 
   <shell command> | %s [OPTIONS] <WordPattern1,[WordPattern2,...WordPatternN]> 
    Options:
        -i: case insensitive
        -I: case sensitive"""%sys.argv[0]
    sys.exit()

opts,args = getopt.getopt(sys.argv[1:],"iI")

if len(args)==0:
    Usage()

if len(opts)==0:
    opts.append(('-i',''))
opts = [ opt[0] for opt in opts ]

try:
    line = sys.stdin.readline()
    while line:
        index = 0
        for wd in args:
            if '-i' in opts:
                pat = re.compile(r"(%s)"%wd,re.I)
                line = pat.sub(fmters[index]%'\\1',line)
            elif '-I' in opts:
                line = line.replace(wd,fmters[index]%wd) 
            else:
                pass
            index = (index+1)%len(fmters)
        print line,
        line = sys.stdin.readline()

except KeyboardInterrupt:
    pass
     
