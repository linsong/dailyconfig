#! /bin/sh
unset autologout
xrdb -load -retain < $HOME/.Xdefaults
gwm &
xmodmap -e "keysym BackSpace = Delete"
xrdb -load -retain $HOME/.Xdefaults
xset b 75 200 50
xset +fp $CCRUN/fonts
X -b
X -k
X -t
X -e
X -l
sleep 2
exit
