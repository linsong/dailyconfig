#! /usr/bin/env sh

uptime | sed -le 's/^.*: \(.*\)$/\1/'
