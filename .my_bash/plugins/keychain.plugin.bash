#!/bin/bash

KEYCHAIN_CMD=$(which keychain)
if [ -n "$KEYCHAIN_CMD" ]; then 
    $KEYCHAIN_CMD ~/.ssh/id_dsa
    . ~/.keychain/$HOSTNAME-sh
fi
