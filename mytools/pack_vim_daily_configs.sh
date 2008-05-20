#!/bin/bash
# pack_configs.sh -- created 2007-12-20, <+NAME+>
# @Last Change: 24-Dez-2004.
# @Revision:    0.0

TS=$(date +%Y-%m-%d)
tar --exclude .svn -czf vim_configs_$TS.tgz  $1

# vi: 
