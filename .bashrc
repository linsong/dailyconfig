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
export LANG=en_US.UTF-8
#export LC_CTYPE="zh_CN"
#LANGUAGE="en_US:en"
#LC_CTYPE=zh_CN.UTF-8
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

export EDITOR='/usr/bin/env vim -u ~/.vim_simple_rc -U NONE --noplugin'
export VISUAL='/usr/bin/env vim -u ~/.vim_simple_rc -U NONE --noplugin'

# set prompt string: user@host and current_directory
# set different prompt basedd on different host 
if [ `hostname` != 'lithetech' ]; then
	PS1='
\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[0m\]
\[[30;47m\][\!]\[[m\] $ '
#elif
else
	PS1='
\[\033[36;40m\]\u@\h \[\033[36;40m\]\w\[\033[0m\]
\[[30;46m\][\!]\[[m\] $ '
fi

if ! [ $(uname) = "Darwin" ]; then 
    eval `dircolors -b ~/DIR_COLORS`
fi

# for details of how to use shopt, read Man bash
shopt -s cdspell extglob dotglob nocaseglob

# Programmable Completion visit http://www.caliban.org/bash for more details
if [ -e /etc/bash_completion ]; then
	source /etc/bash_completion
elif [ -e /sw/etc/bash_completion ]; then
	source /sw/etc/bash_completion
fi

if [ -e ~/.exowebrc ] ; then
 source ~/.exowebrc
fi

#if [ -e ~/laszlorc ] ; then
# source ~/laszlorc
#fi

###########################################################################
###
###            ALIAS defines
###
###########################################################################
# alias {{{
# Some example alias instructions
# alias less='less -r'
# alias rm='rm -i'
# alias whence='type -a'

 alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
 alias ll='ls -lS'
 alias lh='ls -lh'
 alias la='ls -A'
 alias l='ls -CF'
 alias c='clear'
 alias j='jobs'
 alias h='history'
 
 alias xx='rxvt -geometry 125x44 -sr -sl 10000 -fg white -bg black -fb fixedsys -fn fixedsys -tn rxvt -cr SkyBlue -e /bin/bash --login -i&'
# alias xx='xterm -sl 1000 -sb -rightbar -fn 9x15 -bg grey40 -ms red -e /usr/bin/bash &'

 alias ipy='ipython'
 alias ipysh='ipy -profile pysh'
 alias cr='colorize.py'
 alias tip='gvim ~/tips/tips.txt &'

 if [ `uname` = 'Darwin' ]; then 
    alias ls='ls -FG'  
 else
    alias ls='ls -F --color=tty --show-control-chars'
 fi

 #the following configure are only for cygwin 
 if [ $(uname) != 'Darwin' ] && [ $(uname -o) = 'Cygwin' ];then
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

 function v()
 {
    /usr/bin/env vim -u $HOME/.vim_simple_rc -U NONE --noplugin --cmd ":setlocal buftype=nofile" "${@:--}"
 }
 alias tgvim='gvim --cmd ":tabnew" --cmd ":tabfirst"'
 alias vimplugin='cd ~/download/GNU_Tools/WorkPlatform/Vim/configure/download_vimscripts/MostUseful'
###########################################################################
###
###            Function defines
###
###########################################################################
# {{{
# function will stay in the memory after bash start and you can call it like a command. Function 
# is more efficient then normal command

# PAY MORE ATTENTION TO THE FOLLOWING ASPECT WHEN WRITE A FUNCTION:
# 1. there must be some blank around the '=' '>' '<' etc
# 2. 

# Some example functions
 function sayhello() 
 {
	 # print a complement with colors
	 echo  "[36;40;1;5m Hello, $@! [m"; 
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

 function c()
 {
     if [ -e "$1" ]; then
         cd $1
     else
         DEST_DIR = $PWD
     fi

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

 function forport()
 {
	 if [ -n "$1" ]; then
		ssh -R 3000:localhost:22 -l wangwei $1
	 else
		echo ' You must input the destination IP. '
	 fi
 }

# use the following command to start/stop PPPOE 
# rasdial.exe entryname [username [password|*]] [/DOMAIN:domain]
#   [/PHONE:phonenumber] [/CALLBACK:callbacknumber]
#   [/PHONEBOOK:phonebookfile] [/PREFIXSUFFIX]
# rasdial.exe [entryname] /DISCONNECT
 function pppoe()
 {
	 if [ -n "$1" ]; then
		 if [ "$1" = "on" ]; then
			if [ -n "$PPPOEPASSWD" ]; then
				PASSWD=$PPPOEPASSWD
			else
				read -s PASSWD 
				export PPPOEPASSWD=$PASSWD
			fi
			rasdial.exe adsl 100001267980 $PASSWD
		 elif [ "$1" = "off" ]; then
			rasdial.exe /DISCONNECT
		 else
			 cat <<__END
Usage: 
	pppoe [on]/[off]
__END
		fi
	 else
		 cat <<__END
Usage: 
	pppoe [on]/[off]
__END
	 fi
 }
 function desktop()
 {
	 cd /cygdrive/c/Documents\ and\ Settings/$USER/
 }

 function pgrep2()
 {
     local KEYWORD
     KEYWORD={1:?'You must specify a keyword to search'}
	 ps aux | egrep "^[U]SER|[${KEYWORD:0:1}]${KEYWORD:1:}"
 }

 function netlist()
 {
     if [ ! `uname -o` = 'Cygwin' ];then
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

 #growl() { echo -e $'\e]9;'${1}'\007' ; return  ; }
 growl() { netgrowl.py -q -n "ShellNotification" -m "$*"; }

 # }}}

