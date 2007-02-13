#! /usr/bin/env bash

w3m -dump http://vim.sourceforge.net/tips/tip.php?tip_id=$1 |cut -c 28- | sed -ne '1i\
======================================================================\

1,4d
/^\s*\[Add Note\]/Q
p'

