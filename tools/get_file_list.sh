#! /usr/bin/env bash

FILE_LIST_FILE_NAME=FILES.txt

if [[ -e $FILE_LIST_FILE_NAME ]]; then
    cat $FILE_LIST_FILE_NAME 
else
    find . -type f | grep -v '\.svn\|\.swp\|\.swo' | tee $FILE_LIST_FILE_NAME 
fi
