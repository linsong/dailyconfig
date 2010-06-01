# User dependent .bashrc file
# ~/.bashrc: executed by bash for every shell session (including login shell and not login shell)
# settings for only login shell are in ~/.bash_profile .

###########################################################################
###
###            Settings 
###
###########################################################################
# {{{ Settings 
# See man bash for more options...
  # Don't wait for job termination notification
  # set -o notify

  # Don't use ^D to exit
   set -o ignoreeof

  # Don't put duplicate lines in the history.
   export HISTCONTROL=ignoredups

export LESSCHARSET=latin1
export HOSTNAME
PATH=${PATH}:/usr/bin:/bin:/usr/local/bin:~/mytools:~/tools/KeePassX-0.2.2:~/win32tools:~/bin:~/tools

# setting for mail   
MAIL=/var/spool/mail/$USER
export MAIL
#MAILDIR=$HOME/Mail      #you'd better make sure it exists
#DEFAULT=$MAILDIR/mbox   #completely optional
#LOGFILE=$MAILDIR/from   #recommended
 
#set NNTPSERVER=freenews.netfront.net
# start fetchmail deamons to getch mail 
#! ps aux | grep -q fetchmail && fetchmail &

# config about locale
export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8
#export LC_CTYPE="zh_CN"
#LANGUAGE="en_US:en"
#LC_CTYPE=zh_CN.UTF-8

export PYTHONSTARTUP=~/.pythonrc

# environment for rlwrap(readline wrapper tool)
export RLWRAP_HOME=~/.rlwrap

# }}}

##########################################################################
###   the following settings come from myself :)
##########################################################################

# compliments                                               	{{{
# this is the compliment words and demo how to print strings with bkground and foreground color
# about how to print colorful strings, read show_color.sh script for more info
#echo " "
#                   fg bg
#echo "           [36;40;1;5m Welcome to Linux,$(id -un)! [m"
#echo " "
#echo "    [35;1;5m Today is: $(date) [m"

# }}}
###########################################################################
###
###            Settings 
###
###########################################################################
# using the vi style command line
set -o vi

#export EDITOR='/usr/bin/env vim -u /home/vincent/.vim_simple_rc -U NONE --noplugin'
#export VISUAL='/usr/bin/env vim -u /home/vincent/.vim_simple_rc -U NONE --noplugin'
export EDITOR='/usr/local/bin/vim'
export VISUAL='/usr/local/bin/vim'

PS1='
\[\033[31;40m\]\u@\h \[\033[31;40m\]\w\[\033[0m\]
\[[36;40m\][\!]\[[m\] $ '

if ! [ $(uname) = "Darwin" ]; then 
    eval `dircolors -b ~/DIR_COLORS`
fi

# for details of how to use shopt, read Man bash
shopt -s cdspell extglob dotglob nocaseglob
# save histories from all sessions into one history file
shopt -s histappend

# Programmable Completion visit http://www.caliban.org/bash for more details
if [ -e /etc/bash_completion ]; then
	source /etc/bash_completion
elif [ -e /sw/etc/bash_completion ]; then
	source /sw/etc/bash_completion
elif [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi

if [ ! -e $HOME/mytools/fehviewer ]; then
    if [ -n "$(which feh)" ]; then
        ln -s $(which feh) $HOME/mytools/fehviewer
    fi
fi

# function for alias completion support, refs: http://ubuntuforums.org/showthread.php?t=733397 
# Wraps a completion function {{{1
# make-completion-wrapper <actual completion function> <name of new func.>
#                         <command name> <list supplied arguments>
# eg.
#   alias agi='apt-get install'
#   make-completion-wrapper _apt_get _apt_get_install apt-get install
# defines a function called _apt_get_install (that's $2) that will complete
# the 'agi' alias. (complete -F _apt_get_install agi)
#
# complete -p <command name> to find the completion function for a command
function make-completion-wrapper () {
  local function_name="$2"
  local arg_count=$(($#-3))
  local comp_function_name="$1"
  shift 2
  local function="
function $function_name {
  ((COMP_CWORD+=$arg_count))
  COMP_WORDS=( "$@" \${COMP_WORDS[@]:1} )
  "$comp_function_name"
  return 0
}"
  eval "$function"
#  echo $function_name
#  echo "$function"
}

# }}}1

###########################################################################
###
###            ALIAS defines
###
###########################################################################
# alias {{{
# Some example alias instructions

 alias less='less -r'
 alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
 alias ll='ls -lS'
 alias lh='ls -lh'
 alias la='ls -A'
 alias sl='ls -lt'
 alias l='ls -CF'
 alias c='clear'
 #alias j='jobs'
 alias h='history'
 
 alias xx='rxvt -geometry 125x44 -sr -sl 10000 -fg white -bg black -fb fixedsys -fn fixedsys -tn rxvt -cr SkyBlue -e /bin/bash --login -i&'
# alias xx='xterm -sl 1000 -sb -rightbar -fn 9x15 -bg grey40 -ms red -e /usr/bin/bash &'

 alias ipy='ipython'
 alias ipysh='ipy -profile pysh'
 alias cr='colorize.py'
 alias tip='gvim ~/tips/tips.txt &'

 alias radio="mplayer -playlist $HOME/playlist/radio.pls"
 alias tv="nmplayer -playlist $HOME/playlist/tv.pls"
 
 alias myip='wget www.whatismyip.org -qO -'

 if [ `uname` = 'Darwin' ]; then 
    alias ls='ls -FG'  
 else
    alias ls='ls -F --color=tty --show-control-chars'
 fi

 #the following configure are only for cygwin 
 if [ $(uname) != 'Darwin' ] && [ $(uname -s) = 'Cygwin' ];then
	 #export CDPATH="${HOME}:/cygdrive/e"
	 # use rxvt as the default term because it can give more colors
	 alias xx='rxvt -geometry 125x44 -sr -sl 10000 -fg white -bg black -fn fixedsys -fb fixedsys -tn cygwin -cr SkyBlue -e /bin/bash --login -i&'
	 alias pyhelp='s /cygdrive/c/Python24/Doc/ActivePython24.chm'
	 alias wpython='/cygdrive/c/Python24/python.exe'
	 alias e='explorer'
	 alias makensis='c:/Program\ Files/NSIS/makensis.exe'
	 alias pack='python /cygdrive/d/Project/utils/pack/pack.py'
	 alias wrebase='C:/Program\ Files/Microsoft\ Visual\ Studio/VC98/Bin/rebase.exe'
	 alias shutdown='reboot -s now'
	 alias s='cygstart --maximize '
	 alias start='cygstart '
	 alias xwin='sh /usr/X11R6/bin/startxwin.sh'
	 alias linuxcd='s /cygdrive/d/unzipped/ebook/linux/index.htm'
	 alias bashhelp='s /cygdrive/d/unzipped/ebook/linux/OReilly\ -\ Learning\ the\ bash\ Shell\ -\ 2nd\ Edition.chm'
 else
	 alias pyhelp='elinks http://www.python.org/doc/2.4.1/lib'
 fi

 alias pylint="pylint --color=y"
 alias edrc='vim ~/.bashrc'

 # use the sed command to convert file format between Unix an DOS 
 # sed -e 's/.$//' mydos.txt > myunix.txt
 # and I make some alias to make thinks easier
 alias dos2unix="sed -e 's/.$//'"
 alias unix2dos="sed -e 's/$/\r/'"

 alias lsd='find . -type d -maxdepth 1'

 alias tgvim='gvim --cmd ":tabnew" --cmd ":tabfirst"'
 alias vimplugin='cd ~/download/GNU_Tools/WorkPlatform/Vim/configure/download_vimscripts/MostUseful'
 alias edclipbrd='vim +ClipBrd +only'

 alias sshvincent='ssh -A box -t "ssh vincent -t \"screen -x \""'

 alias rlwrap='rlwrap -c'

 alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"' 

 alias wp='cd $PROJECT_DIR'

 # alias for rails 
 alias ss='./script/server'
 alias sg='./script/generate'
 alias sc='./script/console'
 alias r='rake'


 # alias for git
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


#
# alias wg='wcd -g'

# alias md='wcd -m' # mkdir a new directory and add it to treedata
# alias r='wcd -r'  # remove a directory and its treedata if the directory is empty
# alias rt='wcd -rmtree' # remove a directory, all its subdirectory and related treedata
 #}}}
 
 if [ -e "${HOME}/.bash.d" ]; then 
   for i in ${HOME}/.bash.d/*; do 
     source $i; 
   done 
 fi

 if [ -e "${HOME}/.bashrc.local" ]; then
    source ${HOME}/.bashrc.local
 fi

# For kcd
KCD_INIT="/opt/local/etc/kcd.sh.init"
if [ -e "$KCD_INIT" ]; then
	. "$KCD_INIT"
fi

# vim: foldmethod=marker
