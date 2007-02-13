" use this file to overrule the $VIMRUNTIME/scripts.vim 
"   this scripts.vim is loaded before the default checks for file types, which
"   means that your rules override the default rules in
"   $VIMRUNTIME/scripts.vim.
" :help new-filetype-scripts for more details

"##########################################################
"#    detect svn log file type
"##########################################################
if did_filetype()       " filetype already set...
    finish              " ...then don't do these checks
endif
if getline(1) =~ '^-\{72}$'
    setfiletype svnlog
endif
