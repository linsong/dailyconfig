* run following commands: 
    mkfontscale
    mkfontdir
    fc-cache
  simsun.ttc should in ~/.fonts folder, if not, copy it from windows

* copy ~/.fontconfig/zh_CN to /usr/share/language-selector/fontconfig/
* run command: sudo fontconfig-voodoo -s zh_CN
* restart X 

* use fc-list to show all the fonts installed.
