#!/bin/bash

KEYCHAIN_CMD=$(which keychain)
if [ -n "$KEYCHAIN_CMD" ]; then 
  $KEYCHAIN_CMD $SSH_KEY_IN_AGENT
  . ~/.keychain/$HOSTNAME-sh
fi
