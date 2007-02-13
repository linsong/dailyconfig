CYGWINCFGFILES1 := .Xdefault .bash_profile .bashrc .emacs .viper .fetchmailrc .inputrc .lftprc .newsdeliverrc .newsrc .procmailrc .vimrc .gvimrc .lftp .elinks .mutt .ssh .vim .ipython .fvwm DIR_COLORS mytools tools tips elisp Xsetting _ipython
CYGWINCFGFILES2 := $(addprefix $(HOME)/,$(CYGWINCFGFILES1))

#LINUXCFGFILES1 := .Xdefault .bash_profile .bashrc .emacs .viper .fetchmailrc .inputrc .lftprc .procmailrc .vimrc .gvimrc .lftp .elinks .ssh .vim .ipython DIR_COLORS mytools tools tips elisp Xsetting .mozilla-thunderbird

LINUXCFGFILES1 := .Xdefault .bash_profile .bashrc .emacs .viper .fetchmailrc .inputrc .lftprc .procmailrc .vimrc .gvimrc .lftp .elinks .ssh .vim .ipython DIR_COLORS mytools tools tips elisp Xsetting 

LINUXCFGFILES2 := $(addprefix $(HOME)/,$(LINUXCFGFILES1))

CFGDIR := $(HOME)/config

backup: cygwin firefoxcfg AcqURLcfg 

linux: createdir $(LINUXCFGFILES2)
	echo $(LINUXCFGFILES1) | xargs tar --directory=$(HOME) -cjvhf $(CFGDIR)/linuxcfg`date +%Y_%m_%d`.tar.bz2  

cygwin: createdir $(CYGWINCFGFILES2)
	echo $(CYGWINCFGFILES1) | xargs tar --directory=$(HOME) -cjvhf $(CFGDIR)/cygwincfg`date +%Y_%m_%d`.tar.bz2  

firefoxcfg: createdir
	/cygdrive/c/Program\ Files/MozBackup\ 1.3.2/Backup.exe 

AcqURLcfg: createdir
	tar --directory=/cygdrive/c/AcqURL -cjvf $(CFGDIR)/mybookmarks.tar.bz2 MyFavorites.ACQ MyFavoriteswebicons

createdir: 
	if [ ! -d $(CFGDIR) ]; then mkdir $(CFGDIR); fi



