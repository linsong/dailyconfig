#!/bin/bash

alias gco='git checkout'
alias gci='git commit'
alias gbr='git branch'
alias gad='git add'
alias gst='git status'
alias glg='git log'
alias gup='git pull && up.sh'
alias gdiff='git diff'
alias gvdiff='git diff | v'

# following are for git alias
complete -o bashdefault -o default -o nospace -F _git_checkout gco 2>/dev/null \
	|| complete -o default -o nospace -F _git_checkout gco
complete -o bashdefault -o default -o nospace -F _git_commit gci 2>/dev/null \
	|| complete -o default -o nospace -F _git_commit gci
complete -o bashdefault -o default -o nospace -F _git_add gad 2>/dev/null \
	|| complete -o default -o nospace -F _git_add gad
complete -o bashdefault -o default -o nospace -F _git_branch gbr 2>/dev/null \
	|| complete -o default -o nospace -F _git_branch gbr
complete -o bashdefault -o default -o nospace -F _git_log glg 2>/dev/null \
	|| complete -o default -o nospace -F _git_log glg
complete -o bashdefault -o default -o nospace -F _git_diff gdiff 2>/dev/null \
	|| complete -o default -o nospace -F _git_diff gdiff

