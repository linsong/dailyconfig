#!/bin/bash

# For generic functions.

function ips {
  ifconfig | grep "inet " | awk '{ print $2 }'
}

function myip {
  #curl -s ip.appspot.com

  curl ifconfig.me

  #res=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
  #echo "Your public IP is: ${bold_green} $res ${normal}"
}

function mkcd(){
	mkdir -p "$*"
	cd "$*"
}

# View man documentation in Preview
pman () {
   man -t "${1}" | open -f -a $PREVIEW
}


pcurl() {
  curl "${1}" | open -f -a $PREVIEW
}

pri() {
  ri -T "${1}" | open -f -a $PREVIEW
}

quiet() {
	$* &> /dev/null &
}

banish-cookies() {
	rm -r ~/.macromedia ~/.adobe
	ln -s /dev/null ~/.adobe
	ln -s /dev/null ~/.macromedia
}

# disk usage per directory
# in Mac OS X and Linux
usage ()
{
    if [ $(uname) = "Darwin" ]; then
        if [ -n $1 ]; then
            du -hd $1
        else
            du -hd 1
        fi

    elif [ $(uname) = "Linux" ]; then
        if [ -n $1 ]; then
            du -h --max-depth=1 $1
        else
            du -h --max-depth=1
        fi
    fi
}

# List all plugins and functions defined by bash-it
function plugins-help() {
    
    echo "bash-it Plugins Help-Message"
    echo 

    set | grep "()" \
    | sed -e "/^_/d" | grep -v "BASH_ARGC=()" \
    | sed -e "/^\s/d" | grep -v "BASH_LINENO=()" \
    | grep -v "BASH_ARGV=()" \
    | grep -v "BASH_SOURCE=()" \
    | grep -v "DIRSTACK=()" \
    | grep -v "GROUPS=()" \
    | grep -v "BASH_CMDS=()" \
    | grep -v "BASH_ALIASES=()" \
    | grep -v "COMPREPLY=()" | sed -e "s/()//"
}

# back up file with timestamp
# useful for administrators and configs
buf () {
    filename=$1
    filetime=$(date +%Y%m%d_%H%M%S)
    cp ${filename} ${filename}_${filetime}
}

function fpath()
{
  echo $(pwd -P)/$1
}

# list history commands
 function hl()
 {
	if [ "$1" = "--help" ] || [ "$1" = "-h" ]
	 then
		echo "Usage: "
        echo "        list command history using fc builtin command"
		echo "        hl  [FIRST] [LAST] "
	else
		fc -l $@
	fi
 }

# cd and ls 
function cl()
{
cd $1
  ls	
}

function smc() # Show Me Color!
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

function pgrep2()
{
   local KEYWORD
   KEYWORD={1:?'You must specify a keyword to search'}
 ps aux | egrep "^[U]SER|[${KEYWORD:0:1}]${KEYWORD:1:}"
}

function netlist()
{
   if [ ! `uname -s` = 'Cygwin' ];then
      sudo netstat -nlptu | /usr/bin/perl -ape 'if(@F[-1] =~ m#^(\d+)/.+$#){ open CMDLINE, "/proc/$1/cmdline" ; $cmdline = <CMDLINE>; $last_field = $1."#".$cmdline; s#\d+/.+$#$last_field# }'
   fi
}

# use vim to handle files in batch mode just like sed
function vsed()
{
  if [ $# != 2 ]; then
      echo 'Help:                                 '
      echo '   vsed VIM_CMD FILE                  '
      echo ' To operate multiple files at the same time, use for loop: '
      echo '    for i in *; do vsed '+%s/foo/bar/g' $i; done            '
      exit 1
  fi
  VIMCMD=$1
  FILE=$2
  vim -u NONE -i NONE -Nnes "+se ul=-1" $VIMCMD "+update|q"  $FILE
}

function ding()
{
   # to use gnome-osd-client, you need to install package gnome-osd 
   # view manpage for gnome-osd-client for the format of notification message
   # gnome-osd provide a python binding also, not have a look yet.
   if [ -n "$(which gnome-osd-client)" ]; then
       gnome-osd-client -f "<message id='ding' osd_fake_translucent_bg='on' osd_vposition='center' animations='on' hide_timeout='10000' osd_halignment='right'>$*</message>"
   fi
}

g() { growlnotify -s --image ~/Desktop/mylogo.png -n "ShellNotification" -m "$*" "Notification" 2>/dev/null; }
#gm() { echo "Remote Notification" | mail -s "$* on $(hostname)" vincent@seravia.com }

function v()
{
  /usr/bin/env vim -u $HOME/.vim_simple_rc -U NONE --noplugin --cmd ":setlocal buftype=nofile" "${@:--}"
}

function rt()
{
 # shortcut to start rails test
 if [ $* ]; then 
   ruby -Itest $*
   #case $* in 
     #*/unit/*) rake test:units TEST=$* ;;
     #*/functional/*) rake test:functionals TEST=$* ;;
     #*/integration/*) rake test:integration TEST=$* ;;
     #*) echo -n "this test is not supported" ;;
    #esac
 else
   rake 
 fi
}

